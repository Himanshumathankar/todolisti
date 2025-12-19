/// =============================================================================
/// Calendar Screen
/// =============================================================================
/// 
/// Standalone calendar screen wrapper for direct navigation.
/// This is used when accessing calendar via direct route.
/// =============================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'calendar_view.dart';

/// Calendar screen with app bar for standalone navigation.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: const CalendarView(),
    );
  }
}
