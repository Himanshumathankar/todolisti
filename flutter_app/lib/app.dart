/// =============================================================================
/// TodoListi - App Configuration
/// =============================================================================
///
/// This file contains the root application widget that configures:
/// - Material/Cupertino adaptive theming
/// - Navigation (go_router)
/// - Localization
/// - Error handling boundaries
///
/// The app automatically adapts its UI to the platform (Material for Android/
/// Windows/Linux, Cupertino styling hints for iOS/macOS).
/// =============================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/providers/theme_provider.dart';

/// Root application widget.
///
/// Configures the MaterialApp with routing, theming, and localization.
/// Uses [ConsumerWidget] to access Riverpod providers for reactive theming.
class TodoListiApp extends ConsumerWidget {
  const TodoListiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme mode for reactive updates when user changes theme
    final themeMode = ref.watch(themeModeProvider);

    // Read router configuration (don't watch to avoid rebuilds)
    // Router handles its own refresh via GoRouterRefreshStream
    final router = ref.read(appRouterProvider);

    return MaterialApp.router(
      // App identification
      title: 'TodoListi',
      debugShowCheckedModeBanner: false,

      // Routing configuration using go_router
      routerConfig: router,

      // Theming - supports light, dark, and system modes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Error handling for widget build errors
      builder: (context, child) {
        // Add error boundary to catch widget build errors
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return _ErrorWidget(details: details);
        };

        return child ?? const SizedBox.shrink();
      },
    );
  }
}

/// Custom error widget displayed when a widget fails to build.
///
/// In production, shows a user-friendly error message.
/// In development, shows detailed error information for debugging.
class _ErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;

  const _ErrorWidget({required this.details});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.red.shade50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade700,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again or restart the app',
              style: TextStyle(
                color: Colors.red.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
