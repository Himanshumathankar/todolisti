/// =============================================================================
/// App Configuration
/// =============================================================================
/// 
/// Application-wide configuration constants that don't change between
/// environments. These are static values embedded in the app.
/// =============================================================================
library;

/// Application configuration constants.
class AppConfig {
  AppConfig._();
  
  // ============= APP INFO =============
  
  /// Application name displayed in UI
  static const String appName = 'TodoListi';
  
  /// Application version (should match pubspec.yaml)
  static const String version = '1.0.0';
  
  /// Build number
  static const int buildNumber = 1;
  
  /// Support email address
  static const String supportEmail = 'support@todolisti.com';
  
  /// Privacy policy URL
  static const String privacyPolicyUrl = 'https://todolisti.com/privacy';
  
  /// Terms of service URL
  static const String termsUrl = 'https://todolisti.com/terms';
  
  // ============= TASK CONFIGURATION =============
  
  /// Maximum nesting level for subtasks
  /// Prevents infinitely deep task hierarchies
  static const int maxSubtaskDepth = 5;
  
  /// Maximum length for task titles
  static const int maxTaskTitleLength = 500;
  
  /// Maximum length for task descriptions
  static const int maxTaskDescriptionLength = 5000;
  
  /// Default reminder offset in minutes before due time
  static const int defaultReminderOffsetMinutes = 30;
  
  /// Maximum number of reminders per task
  static const int maxRemindersPerTask = 5;
  
  /// Maximum number of tags per task
  static const int maxTagsPerTask = 10;
  
  // ============= PROJECT CONFIGURATION =============
  
  /// Maximum number of projects per user (free tier)
  static const int maxProjectsFree = 10;
  
  /// Maximum number of projects per user (pro tier)
  static const int maxProjectsPro = 100;
  
  // ============= PA/ASSISTANT CONFIGURATION =============
  
  /// Maximum number of assistants per user (free tier)
  static const int maxAssistantsFree = 1;
  
  /// Maximum number of assistants per user (pro tier)
  static const int maxAssistantsPro = 10;
  
  // ============= UI CONFIGURATION =============
  
  /// Default page size for paginated lists
  static const int defaultPageSize = 20;
  
  /// Animation duration for standard transitions
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  /// Short animation duration for quick feedback
  static const Duration animationDurationShort = Duration(milliseconds: 150);
  
  /// Long animation duration for complex transitions
  static const Duration animationDurationLong = Duration(milliseconds: 500);
  
  // ============= CACHE CONFIGURATION =============
  
  /// How long to cache user data locally
  static const Duration userCacheDuration = Duration(hours: 24);
  
  /// How long to cache task data locally
  static const Duration taskCacheDuration = Duration(hours: 1);
}
