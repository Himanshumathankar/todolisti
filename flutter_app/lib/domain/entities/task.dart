/// =============================================================================
/// Task Entity
/// =============================================================================
/// 
/// Core domain entity representing a task in the system.
/// This is the pure business object, independent of data sources.
/// 
/// Uses Freezed for immutability and value equality.
/// =============================================================================
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

/// Priority levels for tasks.
/// 
/// Higher values indicate higher priority.
/// Used for sorting and visual indicators.
enum TaskPriority {
  /// No priority assigned
  none(0),
  /// Low priority - can wait
  low(1),
  /// Medium priority - should be done soon
  medium(2),
  /// High priority - needs attention
  high(3),
  /// Urgent priority - needs immediate attention
  urgent(4);
  
  /// Numeric value for comparison and storage
  final int value;
  
  const TaskPriority(this.value);
  
  /// Create from numeric value.
  factory TaskPriority.fromValue(int value) {
    return TaskPriority.values.firstWhere(
      (p) => p.value == value,
      orElse: () => TaskPriority.none,
    );
  }
}

/// Recurrence pattern for recurring tasks.
enum RecurrencePattern {
  /// No recurrence
  none,
  /// Every day
  daily,
  /// Every week on same day
  weekly,
  /// Every two weeks
  biweekly,
  /// Every month on same date
  monthly,
  /// Every year on same date
  yearly,
  /// Custom recurrence
  custom,
}

/// Task entity representing a single task or subtask.
/// 
/// Tasks can have:
/// - Subtasks (via [parentId])
/// - Due dates and times
/// - Priority levels
/// - Tags and project associations
/// - Recurring patterns
/// - Reminders
@freezed
class Task with _$Task {
  /// Private constructor for custom getters.
  const Task._();
  
  const factory Task({
    /// Unique identifier (UUID)
    required String id,
    
    /// Task title (required, max 500 chars)
    required String title,
    
    /// Optional detailed description
    String? description,
    
    /// Parent task ID for subtasks
    /// If null, this is a root-level task
    String? parentId,
    
    /// Project this task belongs to
    String? projectId,
    
    /// Owner user ID
    required String userId,
    
    /// Priority level (0-4)
    @Default(TaskPriority.none) TaskPriority priority,
    
    /// Due date and time
    DateTime? dueDate,
    
    /// Completion timestamp
    /// If not null, task is completed
    DateTime? completedAt,
    
    /// Google Calendar event ID for sync
    String? googleEventId,
    
    /// Position for ordering within a list
    @Default(0) int position,
    
    /// Tag IDs associated with this task
    @Default([]) List<String> tagIds,
    
    /// Recurrence pattern
    @Default(RecurrencePattern.none) RecurrencePattern recurrence,
    
    /// Custom recurrence rule (iCal RRULE format)
    String? recurrenceRule,
    
    /// Creation timestamp
    required DateTime createdAt,
    
    /// Last update timestamp
    required DateTime updatedAt,
    
    /// Soft delete timestamp
    /// If not null, task is deleted
    DateTime? deletedAt,
    
    /// Sync version for conflict detection
    @Default(0) int syncVersion,
    
    /// Whether this task needs to sync to server
    @Default(false) bool pendingSync,
  }) = _Task;
  
  /// Create from JSON.
  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  
  // ============= COMPUTED PROPERTIES =============
  
  /// Whether the task is completed.
  bool get isCompleted => completedAt != null;
  
  /// Whether the task is deleted.
  bool get isDeleted => deletedAt != null;
  
  /// Whether the task is a subtask.
  bool get isSubtask => parentId != null;
  
  /// Whether the task has a due date.
  bool get hasDueDate => dueDate != null;
  
  /// Whether the task is overdue.
  /// 
  /// A task is overdue if:
  /// - It has a due date
  /// - The due date is in the past
  /// - The task is not completed
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }
  
  /// Whether the task is due today.
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
           dueDate!.month == now.month &&
           dueDate!.day == now.day;
  }
  
  /// Whether the task is due this week.
  bool get isDueThisWeek {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final endOfWeek = now.add(Duration(days: 7 - now.weekday));
    return dueDate!.isBefore(endOfWeek) && dueDate!.isAfter(now);
  }
  
  /// Whether the task is recurring.
  bool get isRecurring => recurrence != RecurrencePattern.none;
  
  /// Whether the task is synced with Google Calendar.
  bool get isSyncedWithCalendar => googleEventId != null;
}

/// Reminder for a task.
/// 
/// Defines when and how to remind the user about a task.
@freezed
class TaskReminder with _$TaskReminder {
  const factory TaskReminder({
    /// Unique identifier
    required String id,
    
    /// Task this reminder belongs to
    required String taskId,
    
    /// When to remind (absolute time)
    required DateTime remindAt,
    
    /// Type of reminder
    @Default(ReminderType.notification) ReminderType type,
    
    /// Whether the reminder has been sent
    @Default(false) bool sent,
  }) = _TaskReminder;
  
  factory TaskReminder.fromJson(Map<String, dynamic> json) =>
    _$TaskReminderFromJson(json);
}

/// Types of reminders.
enum ReminderType {
  /// Push notification
  notification,
  /// Email reminder
  email,
  /// Both notification and email
  both,
}
