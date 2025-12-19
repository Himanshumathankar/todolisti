/// =============================================================================
/// Task List View
/// =============================================================================
/// 
/// Displays tasks in a scrollable list with sections.
/// Supports filtering, sorting, and inline actions.
/// =============================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/colors.dart';
import '../../widgets/task/task_card.dart';
import '../../../domain/entities/task.dart';

/// Sample tasks for UI development.
/// TODO: Replace with actual data from provider
final _sampleTasks = [
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

/// Task list view with grouped sections.
class TaskListView extends ConsumerWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group tasks by status
    final overdueTasks = _sampleTasks.where((t) => t.isOverdue).toList();
    final todayTasks = _sampleTasks.where((t) => t.isDueToday && !t.isOverdue).toList();
    final upcomingTasks = _sampleTasks.where((t) => !t.isDueToday && !t.isOverdue && t.hasDueDate).toList();
    final noDueTasks = _sampleTasks.where((t) => !t.hasDueDate).toList();
    
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Overdue section
        if (overdueTasks.isNotEmpty) ...[
          _buildSectionHeader(context, 'Overdue', AppColors.error, overdueTasks.length),
          ...overdueTasks.map((task) => _buildTaskCard(context, task)),
          const SizedBox(height: 16),
        ],
        
        // Today section
        if (todayTasks.isNotEmpty) ...[
          _buildSectionHeader(context, 'Today', AppColors.primary, todayTasks.length),
          ...todayTasks.map((task) => _buildTaskCard(context, task)),
          const SizedBox(height: 16),
        ],
        
        // Upcoming section
        if (upcomingTasks.isNotEmpty) ...[
          _buildSectionHeader(context, 'Upcoming', AppColors.secondary, upcomingTasks.length),
          ...upcomingTasks.map((task) => _buildTaskCard(context, task)),
          const SizedBox(height: 16),
        ],
        
        // No due date section
        if (noDueTasks.isNotEmpty) ...[
          _buildSectionHeader(context, 'Anytime', AppColors.textSecondaryLight, noDueTasks.length),
          ...noDueTasks.map((task) => _buildTaskCard(context, task)),
          const SizedBox(height: 16),
        ],
        
        // Empty state
        if (_sampleTasks.isEmpty)
          _buildEmptyState(context),
        
        // Bottom padding for FAB
        const SizedBox(height: 80),
      ],
    );
  }
  
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    Color color,
    int count,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTaskCard(BuildContext context, Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TaskCard(
        task: task,
        onTap: () => context.push('/tasks/${task.id}'),
        onComplete: () {
          // TODO: Complete task
        },
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'All caught up!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'No tasks to show. Tap + to add a new task.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
