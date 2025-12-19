/// =============================================================================
/// Focus View
/// =============================================================================
/// 
/// ADHD-friendly single-task focus mode.
/// Minimizes distractions by showing only one task at a time.
/// =============================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/colors.dart';
import '../../../domain/entities/task.dart';

/// Sample focus task.
/// TODO: Replace with actual data from provider
final _focusTask = Task(
  id: '1',
  title: 'Review quarterly report',
  description: 'Check all figures and prepare summary for the stakeholder meeting tomorrow.',
  userId: 'user1',
  priority: TaskPriority.high,
  dueDate: DateTime.now().add(const Duration(hours: 2)),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

/// Focus view for single-task concentration.
/// 
/// Features:
/// - Single task display
/// - Large, easy-to-read format
/// - Timer/Pomodoro support (optional)
/// - Quick complete action
/// - Skip to next task
class FocusView extends ConsumerStatefulWidget {
  const FocusView({super.key});

  @override
  ConsumerState<FocusView> createState() => _FocusViewState();
}

class _FocusViewState extends ConsumerState<FocusView> {
  bool _isTimerRunning = false;
  int _secondsElapsed = 0;
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          
          // Priority badge
          _buildPriorityBadge(),
          const SizedBox(height: 24),
          
          // Task title
          _buildTitle(context),
          const SizedBox(height: 16),
          
          // Task description
          if (_focusTask.description != null) ...[
            _buildDescription(context),
            const SizedBox(height: 24),
          ],
          
          // Due date
          if (_focusTask.hasDueDate) ...[
            _buildDueDate(context),
            const SizedBox(height: 32),
          ],
          
          // Timer
          _buildTimer(context),
          
          const Spacer(),
          
          // Actions
          _buildActions(context),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildPriorityBadge() {
    final priorityColor = AppColors.getPriorityColor(_focusTask.priority.value);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: priorityColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flag,
            size: 16,
            color: priorityColor,
          ),
          const SizedBox(width: 8),
          Text(
            _focusTask.priority.name.toUpperCase(),
            style: TextStyle(
              color: priorityColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTitle(BuildContext context) {
    return Text(
      _focusTask.title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }
  
  Widget _buildDescription(BuildContext context) {
    return Text(
      _focusTask.description!,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: AppColors.textSecondaryLight,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }
  
  Widget _buildDueDate(BuildContext context) {
    final isOverdue = _focusTask.isOverdue;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.access_time,
          size: 20,
          color: isOverdue ? AppColors.error : AppColors.textSecondaryLight,
        ),
        const SizedBox(width: 8),
        Text(
          _formatDueDate(_focusTask.dueDate!),
          style: TextStyle(
            fontSize: 16,
            color: isOverdue ? AppColors.error : AppColors.textSecondaryLight,
            fontWeight: isOverdue ? FontWeight.w600 : null,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimer(BuildContext context) {
    final hours = _secondsElapsed ~/ 3600;
    final minutes = (_secondsElapsed % 3600) ~/ 60;
    final seconds = _secondsElapsed % 60;
    
    return Column(
      children: [
        Text(
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w300,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filled(
              onPressed: _toggleTimer,
              icon: Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow),
              iconSize: 32,
            ),
            const SizedBox(width: 16),
            IconButton.outlined(
              onPressed: _resetTimer,
              icon: const Icon(Icons.refresh),
              iconSize: 24,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        // Skip button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _skipTask,
            icon: const Icon(Icons.skip_next),
            label: const Text('Skip'),
          ),
        ),
        const SizedBox(width: 16),
        
        // Complete button
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _completeTask,
            icon: const Icon(Icons.check),
            label: const Text('Complete'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
  
  void _toggleTimer() {
    setState(() {
      _isTimerRunning = !_isTimerRunning;
    });
    
    if (_isTimerRunning) {
      _startTimer();
    }
  }
  
  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isTimerRunning || !mounted) return false;
      setState(() {
        _secondsElapsed++;
      });
      return true;
    });
  }
  
  void _resetTimer() {
    setState(() {
      _isTimerRunning = false;
      _secondsElapsed = 0;
    });
  }
  
  void _skipTask() {
    // TODO: Skip to next task
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Skipping to next task...')),
    );
  }
  
  void _completeTask() {
    // TODO: Complete task
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task completed! 🎉'),
        backgroundColor: AppColors.success,
      ),
    );
  }
  
  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.isNegative) {
      if (difference.inDays.abs() > 0) {
        return 'Overdue by ${difference.inDays.abs()} day(s)';
      } else if (difference.inHours.abs() > 0) {
        return 'Overdue by ${difference.inHours.abs()} hour(s)';
      } else {
        return 'Overdue by ${difference.inMinutes.abs()} minute(s)';
      }
    } else {
      if (difference.inDays > 0) {
        return 'Due in ${difference.inDays} day(s)';
      } else if (difference.inHours > 0) {
        return 'Due in ${difference.inHours} hour(s)';
      } else {
        return 'Due in ${difference.inMinutes} minute(s)';
      }
    }
  }
}
