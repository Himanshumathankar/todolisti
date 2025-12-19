/// =============================================================================
/// Environment Configuration
/// =============================================================================
///
/// Manages environment-specific configuration values. Uses compile-time
/// constants from dart-define for secure configuration injection.
///
/// Usage in build:
/// flutter run --dart-define=API_BASE_URL=https://api.todolisti.com
/// =============================================================================
library;

/// Environment configuration singleton.
///
/// Provides access to all environment-specific values like API URLs,
/// OAuth credentials, and feature flags.
class Environment {
  Environment._();

  // ============= ENVIRONMENT DETECTION =============

  /// Current environment name (development, staging, production)
  static const String name = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  /// Whether the app is running in production mode
  static bool get isProduction => name == 'production';

  /// Whether the app is running in development mode
  static bool get isDevelopment => name == 'development';

  // ============= API CONFIGURATION =============

  /// Base URL for the backend API
  ///
  /// In development, defaults to laptop IP for phone testing
  /// In production, should be set via dart-define
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.29.197:3000/api/v1',
  );

  /// WebSocket URL for real-time updates
  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'ws://192.168.29.197:3000',
  );

  /// Request timeout in seconds
  static const int requestTimeout = int.fromEnvironment(
    'REQUEST_TIMEOUT',
    defaultValue: 30,
  );

  // ============= GOOGLE OAUTH =============

  /// Google OAuth Web Client ID for authentication
  ///
  /// This is the Web Client ID from Google Cloud Console
  /// Used as serverClientId on Android to get ID tokens for backend verification
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue:
        '954070344756-8krlk9eo2bv1pcjisd4lmehqo1ccbibg.apps.googleusercontent.com',
  );

  /// Google OAuth Client ID specifically for iOS
  static const String googleClientIdIos = String.fromEnvironment(
    'GOOGLE_CLIENT_ID_IOS',
    defaultValue: '',
  );

  // ============= ERROR TRACKING =============

  /// Sentry DSN for error tracking
  ///
  /// Only used in production builds
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  // ============= FEATURE FLAGS =============

  /// Enable offline mode (should always be true)
  static const bool enableOfflineMode = bool.fromEnvironment(
    'ENABLE_OFFLINE_MODE',
    defaultValue: true,
  );

  /// Enable Google Calendar sync feature
  static const bool enableCalendarSync = bool.fromEnvironment(
    'ENABLE_CALENDAR_SYNC',
    defaultValue: true,
  );

  /// Enable debug logging
  static const bool enableDebugLogging = bool.fromEnvironment(
    'ENABLE_DEBUG_LOGGING',
    defaultValue: true,
  );

  // ============= SYNC CONFIGURATION =============

  /// Background sync interval in minutes
  static const int syncIntervalMinutes = int.fromEnvironment(
    'SYNC_INTERVAL_MINUTES',
    defaultValue: 5,
  );

  /// Maximum retry attempts for failed sync operations
  static const int maxSyncRetries = int.fromEnvironment(
    'MAX_SYNC_RETRIES',
    defaultValue: 5,
  );
}
