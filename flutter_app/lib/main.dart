/// =============================================================================
/// TodoListi - Main Entry Point
/// =============================================================================
///
/// This is the entry point for the TodoListi application. It initializes all
/// required services before running the app, including:
/// - Error tracking (Sentry)
/// - Local database (Drift/SQLite)
/// - Secure storage for credentials
/// - Notification service
///
/// The app uses Riverpod for state management, providing a reactive and
/// testable architecture.
/// =============================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app.dart';
import 'core/config/environment.dart';

/// Application entry point.
///
/// Initializes all required services and runs the app wrapped in a
/// [ProviderScope] for Riverpod state management.
Future<void> main() async {
  // Ensure Flutter bindings are initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for mobile (can be changed in settings)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize core services
  await _initializeServices();

  // Initialize Sentry for error tracking in production
  if (Environment.isProduction) {
    await SentryFlutter.init(
      (options) {
        options.dsn = Environment.sentryDsn;
        options.tracesSampleRate = 0.2; // Sample 20% of transactions
        options.environment = Environment.name;
      },
      appRunner: () => _runApp(),
    );
  } else {
    // In development, run without Sentry wrapper
    _runApp();
  }
}

/// Initialize all required services before app startup.
///
/// This includes database initialization, notification setup, and
/// any other services that need to be ready before the UI loads.
Future<void> _initializeServices() async {
  // TODO: Initialize notification service for reminders
  // await NotificationService.instance.initialize();

  // Database is initialized lazily when first accessed via Riverpod
  // but we can pre-warm it here for faster startup
  // final database = AppDatabase();
  // await database.executor.ensureOpen(database);
}

/// Run the app with Riverpod provider scope.
///
/// The [ProviderScope] is the root of the Riverpod tree and must wrap
/// the entire application. It holds all provider states.
void _runApp() {
  runApp(
    // ProviderScope is the root of all Riverpod providers
    // It stores the state of all providers in the widget tree
    ProviderScope(
      observers: [
        // Add observers for debugging in development
        if (!Environment.isProduction) _ProviderLogger(),
      ],
      child: const TodoListiApp(),
    ),
  );
}

/// Logger for Riverpod provider state changes (development only).
///
/// Logs when providers are initialized, updated, or disposed.
/// Useful for debugging state management issues.
class _ProviderLogger extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    debugPrint('Provider added: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    debugPrint('Provider updated: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    debugPrint('Provider disposed: ${provider.name ?? provider.runtimeType}');
  }
}
