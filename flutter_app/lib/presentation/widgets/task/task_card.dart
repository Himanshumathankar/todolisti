/// =============================================================================
/// Task Card Widget
/// =============================================================================
/// 
/// Reusable card widget for displaying a single task.
/// Shows title, priority, due date, and quick actions.
/// =============================================================================
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/colors.dart';
import '../../../domain/entities/task.dart';

/// Task card displaying task information with actions.
/// 
/// Features:
/// - Priority indicator
/// - Checkbox for completion
/// - Due date with overdue styling
/// - Swipe actions (optional)
class TaskCard extends StatelessWidget {
  /// The task to display.
  final Task task;
  
  /// Callback when the card is tapped.
  final VoidCallback? onTap;
  
  /// Callback when the task is marked complete.
  final VoidCallback? onComplete;
  
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              _buildCheckbox(context),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    _buildTitle(context),
                    
                    // Description preview
                    if (task.description != null) ...[
                      const SizedBox(height: 4),
                      _buildDescription(context),
                    ],
                    
                    // Meta info (due date, tags)
                    if (task.hasDueDate) ...[
                      const SizedBox(height: 8),
                      _buildMeta(context),
                    ],
                  ],
                ),
              ),
              
              // Priority indicator
              _buildPriorityIndicator(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCheckbox(BuildContext context) {
    return GestureDetector(
      onTap: onComplete,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: task.isCompleted
                ? AppColors.success
                : AppColors.getPriorityColor(task.priority.value),
            width: 2,
          ),
          color: task.isCompleted ? AppColors.success : Colors.transparent,
        ),
        child: task.isCompleted
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
  
  Widget _buildTitle(BuildContext context) {
    return Text(
      task.title,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w500,
        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
        color: task.isCompleted
            ? Theme.of(context).textTheme.bodySmall?.color
            : null,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
  
  Widget _buildDescription(BuildContext context) {
    return Text(
      task.description!,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.textSecondaryLight,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
  
  Widget _buildMeta(BuildContext context) {
    return Row(
      children: [
        // Due date
        if (task.hasDueDate) ...[
          Icon(
            Icons.access_time,
            size: 14,
            color: task.isOverdue ? AppColors.error : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 4),
          Text(
            _formatDueDate(task.dueDate!),
            style: TextStyle(
              fontSize: 12,
              color: task.isOverdue ? AppColors.error : AppColors.textSecondaryLight,
              fontWeight: task.isOverdue ? FontWeight.w600 : null,
            ),
          ),
        ],
        
        // Subtask count
        // TODO: Add subtask count
        
        // Tags
        // TODO: Add tags
      ],
    );
  }
  
  Widget _buildPriorityIndicator() {
    if (task.priority == TaskPriority.none) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: 4,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.getPriorityColor(task.priority.value),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
  
  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);
    
    if (taskDate == today) {
      return 'Today ${DateFormat.jm().format(date)}';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow ${DateFormat.jm().format(date)}';
    } else if (taskDate.isBefore(today)) {
      final days = today.difference(taskDate).inDays;
      return '$days day${days > 1 ? 's' : ''} ago';
    } else {
      return DateFormat.MMMd().format(date);
    }
  }
}
