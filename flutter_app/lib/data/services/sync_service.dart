/// =============================================================================
/// Sync Service
/// =============================================================================
///
/// Handles offline-first data synchronization between local SQLite database
/// and the remote NestJS backend.
///
/// Features:
/// - Automatic sync when network becomes available
/// - Conflict detection and resolution
/// - Queue-based offline operations
/// - Background sync with exponential backoff
/// =============================================================================
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../datasources/local/database.dart';

/// Sync queue item type alias for clarity
typedef SyncQueueItem = SyncQueueData;

/// Sync status for UI feedback
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  offline,
}

/// Sync state
class SyncState {
  final SyncStatus status;
  final DateTime? lastSyncAt;
  final String? error;
  final int pendingOperations;

  const SyncState({
    this.status = SyncStatus.idle,
    this.lastSyncAt,
    this.error,
    this.pendingOperations = 0,
  });

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncAt,
    String? error,
    int? pendingOperations,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      error: error ?? this.error,
      pendingOperations: pendingOperations ?? this.pendingOperations,
    );
  }
}

/// Sync service provider
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref.watch(apiClientProvider),
    ref.watch(networkInfoProvider),
    ref.watch(appDatabaseProvider),
  );
});

/// Sync state provider
final syncStateProvider =
    StateNotifierProvider<SyncStateNotifier, SyncState>((ref) {
  return SyncStateNotifier(ref.watch(syncServiceProvider));
});

/// Sync state notifier
class SyncStateNotifier extends StateNotifier<SyncState> {
  final SyncService _syncService;
  Timer? _periodicSyncTimer;

  SyncStateNotifier(this._syncService) : super(const SyncState()) {
    _initialize();
  }

  void _initialize() {
    // Start periodic sync every 5 minutes
    _periodicSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => sync(),
    );

    // Initial sync
    sync();
  }

  @override
  void dispose() {
    _periodicSyncTimer?.cancel();
    super.dispose();
  }

  /// Trigger a sync operation
  Future<void> sync() async {
    if (state.status == SyncStatus.syncing) return;

    state = state.copyWith(status: SyncStatus.syncing);

    try {
      final result = await _syncService.sync();

      state = state.copyWith(
        status: SyncStatus.success,
        lastSyncAt: DateTime.now(),
        pendingOperations: result.pendingOperations,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Update pending operations count
  Future<void> updatePendingCount() async {
    final count = await _syncService.getPendingOperationsCount();
    state = state.copyWith(pendingOperations: count);
  }
}

/// Sync result
class SyncResult {
  final int syncedTasks;
  final int syncedProjects;
  final int conflicts;
  final int pendingOperations;

  const SyncResult({
    this.syncedTasks = 0,
    this.syncedProjects = 0,
    this.conflicts = 0,
    this.pendingOperations = 0,
  });
}

/// Sync service implementation
class SyncService {
  final ApiClient _apiClient;
  final NetworkInfo _networkInfo;
  final AppDatabase _database;

  SyncService(this._apiClient, this._networkInfo, this._database);

  // ---------------------------------------------------------------------------
  // Main Sync Logic
  // ---------------------------------------------------------------------------

  /// Perform a full sync operation
  Future<SyncResult> sync() async {
    // Check network connectivity
    if (!await _networkInfo.isConnected) {
      return SyncResult(
        pendingOperations: await getPendingOperationsCount(),
      );
    }

    // Get pending local operations
    final pendingOps = await _database.getPendingSyncOperations();

    // Prepare sync payload
    final payload = await _prepareSyncPayload(pendingOps);

    // Send to server
    final response = await _apiClient.post('/sync', data: payload);

    // Process response
    final result = await _processSyncResponse(response, pendingOps);

    return result;
  }

  /// Prepare sync payload from pending operations
  Future<Map<String, dynamic>> _prepareSyncPayload(
    List<SyncQueueItem> operations,
  ) async {
    final tasks = <Map<String, dynamic>>[];
    final projects = <Map<String, dynamic>>[];

    for (final op in operations) {
      final item = {
        'id': op.entityId,
        'syncVersion': op.syncVersion,
        'operation': op.operation,
        'data': jsonDecode(op.payload),
        'clientUpdatedAt': op.createdAt.toIso8601String(),
      };

      if (op.entityType == 'Task') {
        tasks.add(item);
      } else if (op.entityType == 'Project') {
        projects.add(item);
      }
    }

    return {
      'tasks': tasks,
      'projects': projects,
      'lastSyncAt': await _getLastSyncTimestamp(),
    };
  }

  /// Process sync response from server
  Future<SyncResult> _processSyncResponse(
    dynamic response,
    List<SyncQueueItem> pendingOps,
  ) async {
    int syncedTasks = 0;
    int syncedProjects = 0;
    int conflicts = 0;

    // Process synced tasks
    final syncedTasksList = response['tasks']?['synced'] as List? ?? [];
    for (final task in syncedTasksList) {
      await _upsertLocalTask(task);
      syncedTasks++;
    }

    // Process task conflicts
    final taskConflicts = response['tasks']?['conflicts'] as List? ?? [];
    for (final conflict in taskConflicts) {
      await _handleTaskConflict(conflict);
      conflicts++;
    }

    // Process synced projects
    final syncedProjectsList = response['projects']?['synced'] as List? ?? [];
    for (final project in syncedProjectsList) {
      await _upsertLocalProject(project);
      syncedProjects++;
    }

    // Process project conflicts
    final projectConflicts = response['projects']?['conflicts'] as List? ?? [];
    for (final conflict in projectConflicts) {
      await _handleProjectConflict(conflict);
      conflicts++;
    }

    // Mark successful operations as completed
    for (final op in pendingOps) {
      final hasConflict = taskConflicts
              .any((c) => c['clientVersion']['id'] == op.entityId) ||
          projectConflicts.any((c) => c['clientVersion']['id'] == op.entityId);

      if (!hasConflict) {
        await _database.markSyncOperationCompleted(op.id);
      }
    }

    // Update last sync timestamp
    await _setLastSyncTimestamp(
      DateTime.parse(response['serverTimestamp'] as String),
    );

    return SyncResult(
      syncedTasks: syncedTasks,
      syncedProjects: syncedProjects,
      conflicts: conflicts,
      pendingOperations: await getPendingOperationsCount(),
    );
  }

  // ---------------------------------------------------------------------------
  // Local Database Operations
  // ---------------------------------------------------------------------------

  /// Upsert a task from server data
  Future<void> _upsertLocalTask(Map<String, dynamic> data) async {
    // Convert server task to local format and save
    // Implementation depends on your Task model
    await _database.upsertTaskFromServer(data);
  }

  /// Upsert a project from server data
  Future<void> _upsertLocalProject(Map<String, dynamic> data) async {
    await _database.upsertProjectFromServer(data);
  }

  /// Handle task conflict using Last-Write-Wins strategy
  Future<void> _handleTaskConflict(Map<String, dynamic> conflict) async {
    final serverVersion = conflict['serverVersion'];
    final clientVersion = conflict['clientVersion'];

    // Compare timestamps - server wins by default
    final serverUpdated = DateTime.parse(serverVersion['updatedAt'] as String);
    final clientUpdated =
        DateTime.parse(clientVersion['clientUpdatedAt'] as String);

    if (serverUpdated.isAfter(clientUpdated)) {
      // Server wins - update local with server version
      await _upsertLocalTask(serverVersion);
    } else {
      // Client wins - re-queue the operation with incremented version
      await _database.requeueSyncOperation(
        clientVersion['id'] as String,
        'Task',
        serverVersion['syncVersion'] as int,
      );
    }
  }

  /// Handle project conflict
  Future<void> _handleProjectConflict(Map<String, dynamic> conflict) async {
    final serverVersion = conflict['serverVersion'];
    final clientVersion = conflict['clientVersion'];

    final serverUpdated = DateTime.parse(serverVersion['updatedAt'] as String);
    final clientUpdated =
        DateTime.parse(clientVersion['clientUpdatedAt'] as String);

    if (serverUpdated.isAfter(clientUpdated)) {
      await _upsertLocalProject(serverVersion);
    } else {
      await _database.requeueSyncOperation(
        clientVersion['id'] as String,
        'Project',
        serverVersion['syncVersion'] as int,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Queue Operations
  // ---------------------------------------------------------------------------

  /// Queue a task operation for sync
  Future<void> queueTaskOperation(
    String taskId,
    String operation,
    Map<String, dynamic> data,
    int syncVersion,
  ) async {
    await _database.addSyncOperation(
      entityType: 'Task',
      entityId: taskId,
      operation: operation,
      payload: jsonEncode(data),
      syncVersion: syncVersion,
    );
  }

  /// Queue a project operation for sync
  Future<void> queueProjectOperation(
    String projectId,
    String operation,
    Map<String, dynamic> data,
    int syncVersion,
  ) async {
    await _database.addSyncOperation(
      entityType: 'Project',
      entityId: projectId,
      operation: operation,
      payload: jsonEncode(data),
      syncVersion: syncVersion,
    );
  }

  /// Get count of pending sync operations
  Future<int> getPendingOperationsCount() async {
    final ops = await _database.getPendingSyncOperations();
    return ops.length;
  }

  // ---------------------------------------------------------------------------
  // Timestamp Management
  // ---------------------------------------------------------------------------

  /// Get last sync timestamp from local storage
  Future<String?> _getLastSyncTimestamp() async {
    return _database.getMetadata('lastSyncTimestamp');
  }

  /// Set last sync timestamp
  Future<void> _setLastSyncTimestamp(DateTime timestamp) async {
    await _database.setMetadata(
        'lastSyncTimestamp', timestamp.toIso8601String());
  }

  // ---------------------------------------------------------------------------
  // Full Refresh
  // ---------------------------------------------------------------------------

  /// Force a full refresh from server (discard local changes)
  Future<void> fullRefresh() async {
    if (!await _networkInfo.isConnected) {
      throw Exception('No network connection');
    }

    // Get all data since epoch
    final response = await _apiClient.get('/sync/changes', queryParameters: {
      'since': DateTime.fromMillisecondsSinceEpoch(0).toIso8601String(),
    });

    // Clear local data and repopulate
    await _database.clearAllData();

    final data = response.data as Map<String, dynamic>;

    // Insert tasks
    final tasks = data['tasks'] as List? ?? [];
    for (final task in tasks) {
      await _upsertLocalTask(task);
    }

    // Insert projects
    final projects = data['projects'] as List? ?? [];
    for (final project in projects) {
      await _upsertLocalProject(project);
    }

    // Update timestamp
    await _setLastSyncTimestamp(
      DateTime.parse(data['serverTimestamp'] as String),
    );
  }
}
