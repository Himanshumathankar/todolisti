/// =============================================================================
/// Task Repository Contract
/// =============================================================================
///
/// Defines the interface for task data operations.
/// Implemented by TaskRepositoryImpl in the data layer.
///
/// Uses Either type from dartz for functional error handling.
/// =============================================================================
library;

import 'package:dartz/dartz.dart' hide Task;

import '../../core/errors/failures.dart';
import '../entities/task.dart';

/// Repository interface for task operations.
///
/// All methods return Either<Failure, T> to handle errors functionally.
/// The repository is responsible for coordinating between local and remote
/// data sources and handling sync logic.
abstract class TaskRepository {
  // ============= READ OPERATIONS =============

  /// Get all tasks for the current user.
  ///
  /// [includeCompleted] - Whether to include completed tasks
  /// [projectId] - Optional filter by project
  /// [tagId] - Optional filter by tag
  Future<Either<Failure, List<Task>>> getTasks({
    bool includeCompleted = false,
    String? projectId,
    String? tagId,
  });

  /// Watch tasks for reactive updates.
  ///
  /// Returns a stream of tasks that updates whenever data changes.
  Stream<Either<Failure, List<Task>>> watchTasks({
    bool includeCompleted = false,
    String? projectId,
  });

  /// Get a single task by ID.
  Future<Either<Failure, Task>> getTaskById(String id);

  /// Get subtasks for a parent task.
  Future<Either<Failure, List<Task>>> getSubtasks(String parentId);

  /// Get tasks due on a specific date.
  Future<Either<Failure, List<Task>>> getTasksDueOn(DateTime date);

  /// Get tasks due within a date range.
  Future<Either<Failure, List<Task>>> getTasksInRange(
    DateTime start,
    DateTime end,
  );

  /// Get overdue tasks.
  Future<Either<Failure, List<Task>>> getOverdueTasks();

  /// Search tasks by title and description.
  Future<Either<Failure, List<Task>>> searchTasks(String query);

  // ============= WRITE OPERATIONS =============

  /// Create a new task.
  ///
  /// [task] - The task to create
  /// Returns the created task with generated ID
  Future<Either<Failure, Task>> createTask(Task task);

  /// Update an existing task.
  ///
  /// [task] - The task with updated fields
  Future<Either<Failure, Task>> updateTask(Task task);

  /// Delete a task (soft delete).
  ///
  /// [id] - The task ID to delete
  Future<Either<Failure, void>> deleteTask(String id);

  /// Mark a task as completed.
  ///
  /// [id] - The task ID to complete
  Future<Either<Failure, Task>> completeTask(String id);

  /// Mark a task as incomplete.
  ///
  /// [id] - The task ID to uncomplete
  Future<Either<Failure, Task>> uncompleteTask(String id);

  /// Reorder a task within a list.
  ///
  /// [id] - The task ID to move
  /// [newPosition] - The new position index
  Future<Either<Failure, void>> reorderTask(String id, int newPosition);

  // ============= SUBTASK OPERATIONS =============

  /// Add a subtask to a parent task.
  ///
  /// [parentId] - The parent task ID
  /// [subtask] - The subtask to add
  Future<Either<Failure, Task>> addSubtask(String parentId, Task subtask);

  /// Move a task to become a subtask.
  ///
  /// [taskId] - The task to move
  /// [newParentId] - The new parent task ID (null to make root-level)
  Future<Either<Failure, Task>> moveTask(String taskId, String? newParentId);

  // ============= SYNC OPERATIONS =============

  /// Force sync with the server.
  ///
  /// Pushes local changes and pulls remote updates.
  Future<Either<Failure, void>> sync();

  /// Get pending sync operations count.
  Future<int> getPendingSyncCount();
}
