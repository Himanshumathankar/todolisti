/// =============================================================================
/// App Router Configuration
/// =============================================================================
///
/// Defines the application's navigation structure using go_router.
/// Includes route guards for authentication and deep link handling.
///
/// Features:
/// - Declarative routing
/// - Authentication guards
/// - Deep link support
/// - Shell routes for persistent UI elements
/// =============================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/tasks/task_detail_screen.dart';
import '../../presentation/screens/tasks/create_task_screen.dart';
import '../../presentation/screens/calendar/calendar_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/settings/assistants_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';

/// Route path constants.
///
/// Centralized route paths for type-safe navigation.
class AppRoutes {
  AppRoutes._();

  // Root routes
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/';

  // Task routes
  static const String tasks = '/tasks';
  static const String taskDetail = '/tasks/:id';
  static const String createTask = '/tasks/new';

  // Calendar routes
  static const String calendar = '/calendar';

  // Settings routes
  static const String settings = '/settings';
  static const String assistants = '/settings/assistants';
  static const String profile = '/settings/profile';

  // Helper methods for parameterized routes
  static String taskDetailPath(String id) => '/tasks/$id';
}

/// Global navigator key for accessing navigation outside of widgets.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Provider for the app router.
///
/// Creates a GoRouter instance with authentication-based redirect logic.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    // Refresh the router when auth state changes
    refreshListenable: GoRouterRefreshStream(
      ref.read(authStateProvider.notifier).stream,
    ),

    // Global redirect logic for authentication
    redirect: (context, state) {
      // Read auth state inside redirect to get current value each time
      final authState = ref.read(authStateProvider);
      final authValue = authState.valueOrNull;
      final isLoading = authValue?.isLoading ?? false;
      final isLoggedIn = authValue?.isAuthenticated ?? false;
      final currentPath = state.matchedLocation;

      debugPrint(
          'Router redirect: path=$currentPath, isLoading=$isLoading, isLoggedIn=$isLoggedIn');

      // Show splash while checking auth state
      if (isLoading) {
        return currentPath == AppRoutes.splash ? null : AppRoutes.splash;
      }

      // Once loading is complete, redirect from splash to appropriate screen
      if (currentPath == AppRoutes.splash) {
        return isLoggedIn ? AppRoutes.home : AppRoutes.login;
      }

      // Redirect to login if not authenticated and not already on login
      if (!isLoggedIn && currentPath != AppRoutes.login) {
        return AppRoutes.login;
      }

      // Redirect to home if already authenticated and on login page
      if (isLoggedIn && currentPath == AppRoutes.login) {
        return AppRoutes.home;
      }

      // No redirect needed
      return null;
    },

    // Route definitions
    routes: [
      // Splash screen - shown while checking auth
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Login screen
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Home screen with bottom navigation
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // Task detail (nested under home for smooth transitions)
          GoRoute(
            path: 'tasks/:id',
            name: 'taskDetail',
            builder: (context, state) {
              final taskId = state.pathParameters['id']!;
              return TaskDetailScreen(taskId: taskId);
            },
          ),

          // Create task
          GoRoute(
            path: 'tasks/new',
            name: 'createTask',
            builder: (context, state) => const CreateTaskScreen(),
          ),
        ],
      ),

      // Calendar screen
      GoRoute(
        path: AppRoutes.calendar,
        name: 'calendar',
        builder: (context, state) => const CalendarScreen(),
      ),

      // Settings
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          // Assistants management
          GoRoute(
            path: 'assistants',
            name: 'assistants',
            builder: (context, state) => const AssistantsScreen(),
          ),
        ],
      ),
    ],

    // Error page for unknown routes
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.matchedLocation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Listenable adapter for Stream to trigger GoRouter refresh.
///
/// Used to refresh routes when auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    // Only notify on actual stream events, not on construction
    _subscription = stream.listen((_) {
      debugPrint(
          'GoRouterRefreshStream: Auth state changed, refreshing router');
      notifyListeners();
    });
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
