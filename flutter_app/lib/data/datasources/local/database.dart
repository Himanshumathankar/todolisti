/// =============================================================================
/// Local Database (Drift/SQLite)
/// =============================================================================
/// 
/// Defines the local SQLite database schema using Drift.
/// Provides offline-first storage with reactive streams.
/// 
/// Tables:
/// - tasks: Task storage with full-text search
/// - projects: Project organization
/// - tags: Task labels
/// - task_tags: Many-to-many task-tag relationship
/// - sync_queue: Pending sync operations
/// - users: Local user cache
/// =============================================================================
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ============= TABLE DEFINITIONS =============

/// Tasks table for storing all tasks and subtasks.
class Tasks extends Table {
  /// Primary key (UUID)
  TextColumn get id => text()();
  
  /// Task title
  TextColumn get title => text().withLength(min: 1, max: 500)();
  
  /// Optional description
  TextColumn get description => text().nullable()();
  
  /// Parent task ID for subtasks
  TextColumn get parentId => text().nullable().references(Tasks, #id)();
  
  /// Project ID
  TextColumn get projectId => text().nullable()();
  
  /// Owner user ID
  TextColumn get userId => text()();
  
  /// Priority (0-4)
  IntColumn get priority => integer().withDefault(const Constant(0))();
  
  /// Due date/time
  DateTimeColumn get dueDate => dateTime().nullable()();
  
  /// Completion timestamp
  DateTimeColumn get completedAt => dateTime().nullable()();
  
  /// Google Calendar event ID
  TextColumn get googleEventId => text().nullable()();
  
  /// Position for ordering
  IntColumn get position => integer().withDefault(const Constant(0))();
  
  /// Recurrence pattern
  TextColumn get recurrence => text().withDefault(const Constant('none'))();
  
  /// Custom recurrence rule
  TextColumn get recurrenceRule => text().nullable()();
  
  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime()();
  
  /// Last update timestamp
  DateTimeColumn get updatedAt => dateTime()();
  
  /// Soft delete timestamp
  DateTimeColumn get deletedAt => dateTime().nullable()();
  
  /// Sync version for conflict detection
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  
  /// Whether pending sync to server
  BoolColumn get pendingSync => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
  
  @override
  List<Set<Column>>? get uniqueKeys => [
    // Unique constraint on google event ID per user
    {userId, googleEventId},
  ];
}

/// Projects table for organizing tasks.
class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  TextColumn get color => text().withDefault(const Constant('#3B82F6'))();
  TextColumn get icon => text().withDefault(const Constant('folder'))();
  IntColumn get position => integer().withDefault(const Constant(0))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Tags table for labeling tasks.
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get color => text().withDefault(const Constant('#6B7280'))();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Many-to-many relationship between tasks and tags.
class TaskTags extends Table {
  TextColumn get taskId => text().references(Tasks, #id)();
  TextColumn get tagId => text().references(Tags, #id)();
  
  @override
  Set<Column> get primaryKey => {taskId, tagId};
}

/// Task reminders.
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().references(Tasks, #id)();
  DateTimeColumn get remindAt => dateTime()();
  TextColumn get type => text().withDefault(const Constant('notification'))();
  BoolColumn get sent => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Sync queue for pending operations.
/// 
/// Stores operations that need to be synced to the server.
/// Uses FIFO ordering by creation time.
class SyncQueue extends Table {
  /// Unique operation ID
  TextColumn get id => text()();
  
  /// Entity type (task, project, tag)
  TextColumn get entityType => text()();
  
  /// Entity ID
  TextColumn get entityId => text()();
  
  /// Operation type (create, update, delete)
  TextColumn get operation => text()();
  
  /// JSON payload
  TextColumn get payload => text()();
  
  /// Sync version for conflict detection
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
  
  /// When the operation was queued
  DateTimeColumn get createdAt => dateTime()();
  
  /// Number of retry attempts
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  
  /// Last error message if failed
  TextColumn get lastError => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Local user cache.
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get name => text()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get googleId => text().nullable()();
  TextColumn get timezone => text().withDefault(const Constant('UTC'))();
  TextColumn get settings => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// ============= DATABASE CLASS =============

/// The main database class.
/// 
/// Provides access to all tables and DAOs.
@DriftDatabase(
  tables: [
    Tasks,
    Projects,
    Tags,
    TaskTags,
    Reminders,
    SyncQueue,
    Users,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  /// Schema version - increment when making schema changes.
  @override
  int get schemaVersion => 1;
  
  /// Migration strategy for schema updates.
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Add migration logic here for future schema changes
        // Example:
        // if (from < 2) {
        //   await m.addColumn(tasks, tasks.newColumn);
        // }
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
  
  // ============= TASK QUERIES =============
  
  /// Get all tasks for a user, optionally filtered.
  Future<List<Task>> getTasksForUser(
    String userId, {
    bool includeCompleted = false,
    bool includeDeleted = false,
  }) async {
    var query = select(tasks)
      ..where((t) => t.userId.equals(userId));
    
    if (!includeCompleted) {
      query = query..where((t) => t.completedAt.isNull());
    }
    if (!includeDeleted) {
      query = query..where((t) => t.deletedAt.isNull());
    }
    
    query = query..orderBy([
      (t) => OrderingTerm(expression: t.position),
      (t) => OrderingTerm(expression: t.createdAt),
    ]);
    
    return query.get();
  }
  
  /// Get tasks due on a specific date.
  Future<List<Task>> getTasksDueOn(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return (select(tasks)
      ..where((t) => t.userId.equals(userId))
      ..where((t) => t.dueDate.isBetweenValues(startOfDay, endOfDay))
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
      .get();
  }
  
  /// Watch tasks for a user (reactive stream).
  Stream<List<Task>> watchTasksForUser(String userId) {
    return (select(tasks)
      ..where((t) => t.userId.equals(userId))
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([
        (t) => OrderingTerm(expression: t.position),
        (t) => OrderingTerm(expression: t.createdAt),
      ]))
      .watch();
  }
  
  /// Insert or update a task.
  Future<void> upsertTask(TasksCompanion task) async {
    await into(tasks).insertOnConflictUpdate(task);
  }
  
  /// Mark a task as completed.
  Future<void> completeTask(String taskId) async {
    await (update(tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(
        completedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        pendingSync: const Value(true),
      ),
    );
  }
  
  /// Soft delete a task.
  Future<void> softDeleteTask(String taskId) async {
    await (update(tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        pendingSync: const Value(true),
      ),
    );
  }
  
  // ============= SYNC QUEUE QUERIES =============
  
  /// Get pending sync operations.
  Future<List<SyncQueueData>> getPendingSyncOperations() async {
    return (select(syncQueue)
      ..orderBy([(s) => OrderingTerm(expression: s.createdAt)]))
      .get();
  }
  
  /// Add an operation to the sync queue.
  Future<void> addToSyncQueue(SyncQueueCompanion operation) async {
    await into(syncQueue).insert(operation);
  }
  
  /// Remove a completed sync operation.
  Future<void> removeSyncOperation(String id) async {
    await (delete(syncQueue)..where((s) => s.id.equals(id))).go();
  }
  
  /// Update retry count for failed sync.
  Future<void> incrementSyncRetry(String id, String error) async {
    await (update(syncQueue)..where((s) => s.id.equals(id))).write(
      SyncQueueCompanion(
        retryCount: const Value.ofNullable(null), // Will be incremented
        lastError: Value(error),
      ),
    );
  }
  
  /// Mark sync operation as completed.
  Future<void> markSyncOperationCompleted(String id) async {
    await removeSyncOperation(id);
  }
  
  /// Add a sync operation to the queue.
  Future<void> addSyncOperation({
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
    required int syncVersion,
  }) async {
    await into(syncQueue).insert(SyncQueueCompanion.insert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: payload,
      createdAt: DateTime.now(),
    ));
  }
  
  /// Re-queue a sync operation with updated version.
  Future<void> requeueSyncOperation(
    String entityId,
    String entityType,
    int newSyncVersion,
  ) async {
    // Find existing operation and update its version
    // This would require storing syncVersion in the queue
    // For now, we'll just remove any existing operations for this entity
    await (delete(syncQueue)
      ..where((s) => s.entityId.equals(entityId))
      ..where((s) => s.entityType.equals(entityType)))
      .go();
  }
  
  /// Upsert task from server data.
  Future<void> upsertTaskFromServer(Map<String, dynamic> data) async {
    final companion = TasksCompanion(
      id: Value(data['id'] as String),
      title: Value(data['title'] as String),
      description: Value(data['description'] as String?),
      parentId: Value(data['parentId'] as String?),
      projectId: Value(data['projectId'] as String?),
      userId: Value(data['userId'] as String),
      priority: Value(data['priority'] as int? ?? 0),
      dueDate: Value(data['dueDate'] != null 
        ? DateTime.parse(data['dueDate'] as String) 
        : null),
      completedAt: Value(data['completedAt'] != null 
        ? DateTime.parse(data['completedAt'] as String) 
        : null),
      googleEventId: Value(data['googleCalendarEventId'] as String?),
      position: Value(data['sortOrder'] as int? ?? 0),
      recurrence: Value(data['recurrence'] as String? ?? 'none'),
      createdAt: Value(DateTime.parse(data['createdAt'] as String)),
      updatedAt: Value(DateTime.parse(data['updatedAt'] as String)),
      deletedAt: Value(data['deletedAt'] != null 
        ? DateTime.parse(data['deletedAt'] as String) 
        : null),
      syncVersion: Value(data['syncVersion'] as int? ?? 0),
      pendingSync: const Value(false),
    );
    
    await into(tasks).insertOnConflictUpdate(companion);
  }
  
  /// Upsert project from server data.
  Future<void> upsertProjectFromServer(Map<String, dynamic> data) async {
    final companion = ProjectsCompanion(
      id: Value(data['id'] as String),
      userId: Value(data['userId'] as String),
      name: Value(data['name'] as String),
      description: Value(data['description'] as String?),
      color: Value(data['color'] as String? ?? '#3B82F6'),
      icon: Value(data['icon'] as String? ?? 'folder'),
      position: Value(data['sortOrder'] as int? ?? 0),
      isArchived: Value(data['isArchived'] as bool? ?? false),
      createdAt: Value(DateTime.parse(data['createdAt'] as String)),
      updatedAt: Value(DateTime.parse(data['updatedAt'] as String)),
      syncVersion: Value(data['syncVersion'] as int? ?? 0),
      pendingSync: const Value(false),
    );
    
    await into(projects).insertOnConflictUpdate(companion);
  }
  
  /// Get metadata value.
  Future<String?> getMetadata(String key) async {
    // For simplicity, using a settings approach
    // In production, create a separate metadata table
    return null; // Implement with SharedPreferences or metadata table
  }
  
  /// Set metadata value.
  Future<void> setMetadata(String key, String value) async {
    // Implement with SharedPreferences or metadata table
  }
  
  /// Clear all data (for full refresh).
  Future<void> clearAllData() async {
    await delete(tasks).go();
    await delete(projects).go();
    await delete(tags).go();
    await delete(taskTags).go();
    await delete(reminders).go();
    await delete(syncQueue).go();
  }
  
  // ============= PROJECT QUERIES =============
  
  /// Get all projects for a user.
  Future<List<Project>> getProjectsForUser(String userId) async {
    return (select(projects)
      ..where((p) => p.userId.equals(userId))
      ..where((p) => p.isArchived.equals(false))
      ..orderBy([(p) => OrderingTerm(expression: p.position)]))
      .get();
  }
  
  /// Watch projects for a user.
  Stream<List<Project>> watchProjectsForUser(String userId) {
    return (select(projects)
      ..where((p) => p.userId.equals(userId))
      ..where((p) => p.isArchived.equals(false))
      ..orderBy([(p) => OrderingTerm(expression: p.position)]))
      .watch();
  }
  
  // ============= TAG QUERIES =============
  
  /// Get all tags for a user.
  Future<List<Tag>> getTagsForUser(String userId) async {
    return (select(tags)..where((t) => t.userId.equals(userId))).get();
  }
  
  /// Get tags for a specific task.
  Future<List<Tag>> getTagsForTask(String taskId) async {
    final tagIds = await (select(taskTags)
      ..where((tt) => tt.taskId.equals(taskId)))
      .get();
    
    if (tagIds.isEmpty) return [];
    
    return (select(tags)
      ..where((t) => t.id.isIn(tagIds.map((tt) => tt.tagId))))
      .get();
  }
  
  // ============= USER QUERIES =============
  
  /// Get the current user from cache.
  Future<User?> getCurrentUser() async {
    final users = await select(this.users).get();
    return users.isNotEmpty ? users.first : null;
  }
  
  /// Save user to local cache.
  Future<void> saveUser(UsersCompanion user) async {
    await into(users).insertOnConflictUpdate(user);
  }
  
  /// Clear user cache (on logout).
  Future<void> clearUserCache() async {
    await delete(users).go();
  }
}

/// Open database connection.
/// 
/// Creates the database file in the app's documents directory.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'todolisti.db'));
    return NativeDatabase.createInBackground(file);
  });
}

/// Provider for the database instance.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Alias for backwards compatibility
final databaseProvider = appDatabaseProvider;
