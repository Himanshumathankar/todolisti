/// =============================================================================
/// Calendar View
/// =============================================================================
/// 
/// Timeline/calendar view for visualizing tasks across time.
/// Supports day, week, and month views.
/// =============================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../theme/colors.dart';
import '../../../domain/entities/task.dart';

/// Calendar view mode.
enum CalendarViewMode { day, week, month }

/// Current calendar view mode provider.
final calendarViewModeProvider = StateProvider<CalendarViewMode>(
  (ref) => CalendarViewMode.day,
);

/// Selected date provider.
final selectedDateProvider = StateProvider<DateTime>(
  (ref) => DateTime.now(),
);

/// Calendar view with timeline display.
class CalendarView extends ConsumerWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(calendarViewModeProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    
    return Column(
      children: [
        // View mode selector and date navigation
        _buildHeader(context, ref, viewMode, selectedDate),
        
        // Calendar content
        Expanded(
          child: _buildCalendarContent(context, ref, viewMode, selectedDate),
        ),
      ],
    );
  }
  
  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    CalendarViewMode viewMode,
    DateTime selectedDate,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Date navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _navigateDate(ref, viewMode, -1),
              ),
              GestureDetector(
                onTap: () => _showDatePicker(context, ref),
                child: Text(
                  _formatDateHeader(selectedDate, viewMode),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _navigateDate(ref, viewMode, 1),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // View mode toggle
          SegmentedButton<CalendarViewMode>(
            segments: const [
              ButtonSegment(
                value: CalendarViewMode.day,
                label: Text('Day'),
                icon: Icon(Icons.view_day),
              ),
              ButtonSegment(
                value: CalendarViewMode.week,
                label: Text('Week'),
                icon: Icon(Icons.view_week),
              ),
              ButtonSegment(
                value: CalendarViewMode.month,
                label: Text('Month'),
                icon: Icon(Icons.calendar_month),
              ),
            ],
            selected: {viewMode},
            onSelectionChanged: (Set<CalendarViewMode> selected) {
              ref.read(calendarViewModeProvider.notifier).state = selected.first;
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildCalendarContent(
    BuildContext context,
    WidgetRef ref,
    CalendarViewMode viewMode,
    DateTime selectedDate,
  ) {
    switch (viewMode) {
      case CalendarViewMode.day:
        return _buildDayView(context, selectedDate);
      case CalendarViewMode.week:
        return _buildWeekView(context, selectedDate);
      case CalendarViewMode.month:
        return _buildMonthView(context, ref, selectedDate);
    }
  }
  
  /// Day view with hourly timeline.
  Widget _buildDayView(BuildContext context, DateTime date) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 24,
      itemBuilder: (context, hour) {
        return _buildTimeSlot(context, hour, date);
      },
    );
  }
  
  Widget _buildTimeSlot(BuildContext context, int hour, DateTime date) {
    final timeText = DateFormat.j().format(
      DateTime(date.year, date.month, date.day, hour),
    );
    
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time label
          SizedBox(
            width: 60,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                timeText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
          ),
          
          // Task slot
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              // TODO: Add tasks for this time slot
            ),
          ),
        ],
      ),
    );
  }
  
  /// Week view with day columns.
  Widget _buildWeekView(BuildContext context, DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    
    return Column(
      children: [
        // Day headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(7, (index) {
              final day = startOfWeek.add(Duration(days: index));
              final isToday = _isToday(day);
              
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isToday ? AppColors.primary.withValues(alpha: 0.1) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat.E().format(day),
                        style: TextStyle(
                          fontSize: 12,
                          color: isToday ? AppColors.primary : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        day.day.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isToday ? AppColors.primary : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Week content placeholder
        Expanded(
          child: Center(
            child: Text(
              'Week view tasks will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  /// Month view with day grid.
  Widget _buildMonthView(BuildContext context, WidgetRef ref, DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    final totalCells = ((firstWeekday - 1) + daysInMonth + 6) ~/ 7 * 7;
    
    return Column(
      children: [
        // Day of week headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Day grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              final dayOffset = index - (firstWeekday - 1);
              
              if (dayOffset < 0 || dayOffset >= daysInMonth) {
                return const SizedBox.shrink();
              }
              
              final day = DateTime(date.year, date.month, dayOffset + 1);
              final isToday = _isToday(day);
              final isSelected = _isSameDay(day, date);
              
              return GestureDetector(
                onTap: () {
                  ref.read(selectedDateProvider.notifier).state = day;
                  ref.read(calendarViewModeProvider.notifier).state = CalendarViewMode.day;
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isToday
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      (dayOffset + 1).toString(),
                      style: TextStyle(
                        fontWeight: isToday ? FontWeight.bold : null,
                        color: isSelected
                            ? Colors.white
                            : isToday
                                ? AppColors.primary
                                : null,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  void _navigateDate(WidgetRef ref, CalendarViewMode viewMode, int direction) {
    final current = ref.read(selectedDateProvider);
    DateTime newDate;
    
    switch (viewMode) {
      case CalendarViewMode.day:
        newDate = current.add(Duration(days: direction));
        break;
      case CalendarViewMode.week:
        newDate = current.add(Duration(days: 7 * direction));
        break;
      case CalendarViewMode.month:
        newDate = DateTime(current.year, current.month + direction, current.day);
        break;
    }
    
    ref.read(selectedDateProvider.notifier).state = newDate;
  }
  
  void _showDatePicker(BuildContext context, WidgetRef ref) async {
    final current = ref.read(selectedDateProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      ref.read(selectedDateProvider.notifier).state = picked;
    }
  }
  
  String _formatDateHeader(DateTime date, CalendarViewMode viewMode) {
    switch (viewMode) {
      case CalendarViewMode.day:
        return DateFormat.yMMMMd().format(date);
      case CalendarViewMode.week:
        final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return '${DateFormat.MMMd().format(startOfWeek)} - ${DateFormat.MMMd().format(endOfWeek)}';
      case CalendarViewMode.month:
        return DateFormat.yMMMM().format(date);
    }
  }
  
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
