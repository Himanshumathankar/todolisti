/// =============================================================================
/// API Constants
/// =============================================================================
///
/// Defines all API endpoint paths and HTTP-related constants.
/// Centralizes API paths for easy maintenance and refactoring.
/// =============================================================================
library;

/// API endpoint paths and HTTP constants.
class ApiConstants {
  ApiConstants._();

  // ============= HTTP HEADERS =============

  /// Authorization header key
  static const String authHeader = 'Authorization';

  /// Bearer token prefix
  static const String bearerPrefix = 'Bearer ';

  /// Content type header key
  static const String contentTypeHeader = 'Content-Type';

  /// JSON content type
  static const String contentTypeJson = 'application/json';

  /// Device ID header for multi-device sync
  static const String deviceIdHeader = 'X-Device-ID';

  /// Sync version header for conflict detection
  static const String syncVersionHeader = 'X-Sync-Version';

  // ============= AUTH ENDPOINTS =============

  /// Google OAuth initiation (for web)
  static const String authGoogle = '/auth/google';

  /// Google OAuth for mobile apps (ID token verification)
  static const String authGoogleMobile = '/auth/google/mobile';

  /// Google OAuth callback
  static const String authGoogleCallback = '/auth/google/callback';

  /// Refresh access token
  static const String authRefresh = '/auth/refresh';

  /// Logout and invalidate tokens
  static const String authLogout = '/auth/logout';

  /// Get current user profile
  static const String authMe = '/auth/me';

  // ============= TASK ENDPOINTS =============

  /// Tasks base path
  static const String tasks = '/tasks';

  /// Single task by ID (append /:id)
  static String taskById(String id) => '/tasks/$id';

  /// Complete a task
  static String taskComplete(String id) => '/tasks/$id/complete';

  /// Reorder task
  static String taskReorder(String id) => '/tasks/$id/reorder';

  /// Task subtasks
  static String taskSubtasks(String id) => '/tasks/$id/subtasks';

  // ============= PROJECT ENDPOINTS =============

  /// Projects base path
  static const String projects = '/projects';

  /// Single project by ID
  static String projectById(String id) => '/projects/$id';

  /// Tasks in a project
  static String projectTasks(String id) => '/projects/$id/tasks';

  // ============= TAG ENDPOINTS =============

  /// Tags base path
  static const String tags = '/tags';

  /// Single tag by ID
  static String tagById(String id) => '/tags/$id';

  // ============= PERMISSION ENDPOINTS =============

  /// Permissions base path (PA system)
  static const String permissions = '/permissions';

  /// Invite assistant
  static const String permissionsInvite = '/permissions/invite';

  /// Single permission by ID
  static String permissionById(String id) => '/permissions/$id';

  /// Accounts I can access as a PA
  static const String permissionsAccessible = '/permissions/accessible';

  // ============= CALENDAR ENDPOINTS =============

  /// Calendar sync base path
  static const String calendar = '/calendar';

  /// Connect Google Calendar
  static const String calendarConnect = '/calendar/connect';

  /// Disconnect Google Calendar
  static const String calendarDisconnect = '/calendar/disconnect';

  /// Force sync now
  static const String calendarSync = '/calendar/sync';

  /// Get sync status
  static const String calendarStatus = '/calendar/status';

  // ============= SYNC ENDPOINTS =============

  /// Sync base path
  static const String sync = '/sync';

  /// Push local changes
  static const String syncPush = '/sync/push';

  /// Pull remote changes
  static const String syncPull = '/sync/pull';

  /// Get sync status
  static const String syncStatus = '/sync/status';

  // ============= USER ENDPOINTS =============

  /// User profile
  static const String userProfile = '/users/profile';

  /// Update user settings
  static const String userSettings = '/users/settings';

  // ============= AUDIT ENDPOINTS =============

  /// Audit logs
  static const String auditLogs = '/audit';
}
