/// =============================================================================
/// Task Provider
/// =============================================================================
/// 
/// State management for tasks using Riverpod.
/// Handles CRUD operations, filtering, and sync.
/// =============================================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';

/// =============================================================================
/// Task List State
/// =============================================================================

/// State class for task list.
class TaskListState {
  final List<Task> tasks;
  final bool isLoading;
  final String? error;
  final TaskFilter filter;
  final TaskSort sort;
  
  const TaskListState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
    this.filter = const TaskFilter(),
    this.sort = TaskSort.dueDate,
  });
  
  TaskListState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? error,
    TaskFilter? filter,
    TaskSort? sort,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
    );
  }
  
  /// Get filtered and sorted tasks.
  List<Task> get filteredTasks {
    var result = tasks.where((task) {
      // Apply completed filter
      if (!filter.showCompleted && task.isCompleted) return false;
      
      // Apply priority filter
      if (filter.priorities.isNotEmpty && 
          !filter.priorities.contains(task.priority)) {
        return false;
      }
      
      // Apply project filter
      if (filter.projectId != null && task.projectId != filter.projectId) return false;
      
      // Apply search filter
      if (filter.searchQuery.isNotEmpty) {
        final query = filter.searchQuery.toLowerCase();
        if (!task.title.toLowerCase().contains(query) &&
            !(task.description?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    // Apply sorting
    result.sort((a, b) {
      switch (sort) {
        case TaskSort.dueDate:
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        case TaskSort.priority:
          return b.priority.value.compareTo(a.priority.value);
        case TaskSort.createdAt:
          return b.createdAt.compareTo(a.createdAt);
        case TaskSort.title:
          return a.title.compareTo(b.title);
      }
    });
    
    return result;
  }
  
  /// Get overdue tasks.
  List<Task> get overdueTasks => 
      filteredTasks.where((t) => t.isOverdue).toList();
  
  /// Get tasks due today.
  List<Task> get todayTasks => 
      filteredTasks.where((t) => t.isDueToday && !t.isOverdue).toList();
  
  /// Get upcoming tasks (not due today, not overdue).
  List<Task> get upcomingTasks => 
      filteredTasks.where((t) => 
          t.hasDueDate && !t.isDueToday && !t.isOverdue).toList();
  
  /// Get tasks without due date.
  List<Task> get anytimeTasks => 
      filteredTasks.where((t) => !t.hasDueDate).toList();
}

/// Filter options for tasks.
class TaskFilter {
  final bool showCompleted;
  final Set<TaskPriority> priorities;
  final String? projectId;
  final String searchQuery;
  
  const TaskFilter({
    this.showCompleted = false,
    this.priorities = const {},
    this.projectId,
    this.searchQuery = '',
  });
  
  TaskFilter copyWith({
    bool? showCompleted,
    Set<TaskPriority>? priorities,
    String? projectId,
    String? searchQuery,
  }) {
    return TaskFilter(
      showCompleted: showCompleted ?? this.showCompleted,
      priorities: priorities ?? this.priorities,
      projectId: projectId ?? this.projectId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Sort options for tasks.
enum TaskSort { dueDate, priority, createdAt, title }

/// =============================================================================
/// Task Notifier
/// =============================================================================

/// Manages task state and operations.
class TaskNotifier extends StateNotifier<TaskListState> {
  TaskNotifier() : super(const TaskListState()) {
    _loadTasks();
  }
  
  /// Load tasks from repository.
  Future<void> _loadTasks() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // TODO: Load from repository
      // For now, use sample data
      await Future.delayed(const Duration(milliseconds: 500));
      
      final sampleTasks = [
        Task(
          id: '1',
          title: 'Review quarterly report',
          description: 'Check all figures and prepare summary',
          userId: 'user1',
          priority: TaskPriority.high,
          dueDate: DateTime.now().add(const Duration(hours: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Task(
          id: '2',
          title: 'Team standup meeting',
          userId: 'user1',
          priority: TaskPriority.medium,
          dueDate: DateTime.now().add(const Duration(hours: 4)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Task(
          id: '3',
          title: 'Reply to client emails',
          userId: 'user1',
          priority: TaskPriority.low,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Task(
          id: '4',
          title: 'Prepare presentation slides',
          description: 'For the product launch next week',
          userId: 'user1',
          priority: TaskPriority.urgent,
          dueDate: DateTime.now().subtract(const Duration(hours: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      
      state = state.copyWith(
        tasks: sampleTasks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Refresh tasks from repository.
  Future<void> refresh() async {
    await _loadTasks();
  }
  
  /// Create a new task.
  Future<void> createTask(Task task) async {
    try {
      // TODO: Save to repository
      state = state.copyWith(
        tasks: [...state.tasks, task],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  /// Update an existing task.
  Future<void> updateTask(Task task) async {
    try {
      // TODO: Save to repository
      final index = state.tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        final updatedTasks = [...state.tasks];
        updatedTasks[index] = task;
        state = state.copyWith(tasks: updatedTasks);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  /// Delete a task.
  Future<void> deleteTask(String taskId) async {
    try {
      // TODO: Delete from repository
      state = state.copyWith(
        tasks: state.tasks.where((t) => t.id != taskId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  /// Toggle task completion.
  Future<void> toggleComplete(String taskId) async {
    try {
      final task = state.tasks.firstWhere((t) => t.id == taskId);
      final updatedTask = task.copyWith(
        completedAt: task.isCompleted ? null : DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await updateTask(updatedTask);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  /// Update filter options.
  void setFilter(TaskFilter filter) {
    state = state.copyWith(filter: filter);
  }
  
  /// Update sort option.
  void setSort(TaskSort sort) {
    state = state.copyWith(sort: sort);
  }
  
  /// Toggle showing completed tasks.
  void toggleShowCompleted() {
    state = state.copyWith(
      filter: state.filter.copyWith(
        showCompleted: !state.filter.showCompleted,
      ),
    );
  }
  
  /// Set search query.
  void setSearchQuery(String query) {
    state = state.copyWith(
      filter: state.filter.copyWith(searchQuery: query),
    );
  }
  
  /// Clear error.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// =============================================================================
/// Providers
/// =============================================================================

/// Main task list provider.
final taskListProvider = StateNotifierProvider<TaskNotifier, TaskListState>((ref) {
  return TaskNotifier();
});

/// Overdue tasks provider.
final overdueTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(taskListProvider).overdueTasks;
});

/// Today's tasks provider.
final todayTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(taskListProvider).todayTasks;
});

/// Upcoming tasks provider.
final upcomingTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(taskListProvider).upcomingTasks;
});

/// Anytime tasks provider.
final anytimeTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(taskListProvider).anytimeTasks;
});

/// Single task provider by ID.
final taskByIdProvider = Provider.family<Task?, String>((ref, id) {
  final tasks = ref.watch(taskListProvider).tasks;
  try {
    return tasks.firstWhere((t) => t.id == id);
  } catch (_) {
    return null;
  }
});
