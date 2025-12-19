/// =============================================================================
/// Home Screen
/// =============================================================================
/// 
/// Main screen with bottom navigation for accessing different views.
/// Implements an ADHD-friendly layout with minimal distractions.
/// =============================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../tasks/task_list_view.dart';
import '../calendar/calendar_view.dart';
import '../focus/focus_view.dart';

/// Current tab index provider.
final currentTabProvider = StateProvider<int>((ref) => 0);

/// Home screen with bottom navigation.
/// 
/// Contains three main views:
/// - Tasks: List view of all tasks
/// - Calendar: Timeline/calendar view
/// - Focus: Single task focus mode (ADHD-friendly)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);
    final user = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: _buildAppBar(context, ref, user),
      body: _buildBody(currentTab),
      bottomNavigationBar: _buildBottomNav(context, ref, currentTab),
      floatingActionButton: _buildFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
  
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
  ) {
    return AppBar(
      title: Text(_getTitle(ref.watch(currentTabProvider))),
      actions: [
        // Sync indicator
        IconButton(
          icon: const Icon(Icons.sync),
          onPressed: () {
            // TODO: Trigger sync
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Syncing...')),
            );
          },
          tooltip: 'Sync now',
        ),
        
        // User avatar / Settings
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => context.push('/settings'),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: user?.avatarUrl != null
                  ? NetworkImage(user.avatarUrl)
                  : null,
              child: user?.avatarUrl == null
                  ? Text(
                      user?.initials ?? '?',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
  
  String _getTitle(int currentTab) {
    switch (currentTab) {
      case 0:
        return 'Tasks';
      case 1:
        return 'Calendar';
      case 2:
        return 'Focus';
      default:
        return 'TodoListi';
    }
  }
  
  Widget _buildBody(int currentTab) {
    switch (currentTab) {
      case 0:
        return const TaskListView();
      case 1:
        return const CalendarView();
      case 2:
        return const FocusView();
      default:
        return const TaskListView();
    }
  }
  
  Widget _buildBottomNav(BuildContext context, WidgetRef ref, int currentTab) {
    return BottomNavigationBar(
      currentIndex: currentTab,
      onTap: (index) => ref.read(currentTabProvider.notifier).state = index,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.check_box_outlined),
          activeIcon: Icon(Icons.check_box),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.center_focus_strong_outlined),
          activeIcon: Icon(Icons.center_focus_strong),
          label: 'Focus',
        ),
      ],
    );
  }
  
  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.push('/tasks/new'),
      child: const Icon(Icons.add),
    );
  }
}
