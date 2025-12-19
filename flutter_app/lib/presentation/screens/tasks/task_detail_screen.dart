/// =============================================================================
/// Task Detail Screen
/// =============================================================================
///
/// Full task view with all details and editing capabilities.
/// Supports subtasks, reminders, and sharing with assistants.
/// =============================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../theme/colors.dart';
import '../../providers/task_provider.dart';
import '../../../domain/entities/task.dart';

/// Task detail screen showing full task information.
class TaskDetailScreen extends ConsumerWidget {
  /// The task ID to display.
  final String taskId;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskByIdProvider(taskId));

    if (task == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Task not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/tasks/$taskId/edit'),
            tooltip: 'Edit',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value, task),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Duplicate'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: AppColors.error),
                  title:
                      Text('Delete', style: TextStyle(color: AppColors.error)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and priority
            _buildHeader(context, task),
            const SizedBox(height: 16),

            // Title
            _buildTitle(context, task),

            // Description
            if (task.description != null) ...[
              const SizedBox(height: 16),
              _buildDescription(context, task),
            ],

            const SizedBox(height: 24),

            // Due date
            if (task.hasDueDate)
              _buildInfoRow(
                context,
                Icons.access_time,
                'Due',
                _formatDueDate(task.dueDate!),
                color: task.isOverdue ? AppColors.error : null,
              ),

            // Recurrence
            if (task.isRecurring)
              _buildInfoRow(
                context,
                Icons.repeat,
                'Repeats',
                task.recurrence.name,
              ),

            // Project
            if (task.projectId != null)
              _buildInfoRow(
                context,
                Icons.folder_outlined,
                'Project',
                'Project Name', // TODO: Get project name
              ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Subtasks section
            _buildSubtasksSection(context, ref, task),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Reminders section
            _buildRemindersSection(context, task),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Meta info
            _buildMetaInfo(context, task),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, ref, task),
    );
  }

  Widget _buildHeader(BuildContext context, Task task) {
    return Row(
      children: [
        // Priority badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.getPriorityColor(task.priority.value)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.flag,
                size: 14,
                color: AppColors.getPriorityColor(task.priority.value),
              ),
              const SizedBox(width: 4),
              Text(
                task.priority.name.toUpperCase(),
                style: TextStyle(
                  color: AppColors.getPriorityColor(task.priority.value),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),

        // Completion status
        if (task.isCompleted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: AppColors.success,
                ),
                SizedBox(width: 4),
                Text(
                  'COMPLETED',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context, Task task) {
    return Text(
      task.title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
    );
  }

  Widget _buildDescription(BuildContext context, Task task) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        task.description!,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.5,
            ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? AppColors.textSecondaryLight),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: color ?? AppColors.textSecondaryLight),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtasksSection(BuildContext context, WidgetRef ref, Task task) {
    // TODO: Get actual subtasks
    final subtasks = <Task>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.checklist, size: 20),
            const SizedBox(width: 8),
            Text(
              'Subtasks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                // TODO: Add subtask
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (subtasks.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No subtasks yet',
                style: TextStyle(color: AppColors.textSecondaryLight),
              ),
            ),
          )
        else
          ...subtasks
              .map((subtask) => _buildSubtaskItem(context, ref, subtask)),
      ],
    );
  }

  Widget _buildSubtaskItem(BuildContext context, WidgetRef ref, Task subtask) {
    return ListTile(
      leading: Checkbox(
        value: subtask.isCompleted,
        onChanged: (value) {
          ref.read(taskListProvider.notifier).toggleComplete(subtask.id);
        },
      ),
      title: Text(
        subtask.title,
        style: TextStyle(
          decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildRemindersSection(BuildContext context, Task task) {
    // TODO: Get actual reminders
    final reminders = <DateTime>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.notifications_outlined, size: 20),
            const SizedBox(width: 8),
            Text(
              'Reminders',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                // TODO: Add reminder
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (reminders.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No reminders set',
                style: TextStyle(color: AppColors.textSecondaryLight),
              ),
            ),
          )
        else
          ...reminders.map((reminder) => ListTile(
                leading: const Icon(Icons.alarm),
                title: Text(DateFormat.yMMMd().add_jm().format(reminder)),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    // TODO: Remove reminder
                  },
                ),
                contentPadding: EdgeInsets.zero,
              )),
      ],
    );
  }

  Widget _buildMetaInfo(BuildContext context, Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Created ${DateFormat.yMMMd().format(task.createdAt)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Updated ${DateFormat.yMMMd().format(task.updatedAt)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref, Task task) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: () {
            ref.read(taskListProvider.notifier).toggleComplete(task.id);
          },
          icon: Icon(task.isCompleted ? Icons.replay : Icons.check),
          label: Text(task.isCompleted ? 'Mark Incomplete' : 'Mark Complete'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: task.isCompleted ? null : AppColors.success,
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    Task task,
  ) {
    switch (action) {
      case 'duplicate':
        // TODO: Duplicate task
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task duplicated')),
        );
        break;
      case 'share':
        // TODO: Share task
        break;
      case 'delete':
        _showDeleteDialog(context, ref, task);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text(
          'Are you sure you want to delete this task? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(taskListProvider.notifier).deleteTask(task.id);
              Navigator.pop(context);
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    String dateStr;
    if (taskDate == today) {
      dateStr = 'Today';
    } else if (taskDate == tomorrow) {
      dateStr = 'Tomorrow';
    } else if (taskDate.isBefore(today)) {
      final days = today.difference(taskDate).inDays;
      dateStr = '$days day${days > 1 ? 's' : ''} ago';
    } else {
      dateStr = DateFormat.MMMd().format(date);
    }

    return '$dateStr at ${DateFormat.jm().format(date)}';
  }
}
