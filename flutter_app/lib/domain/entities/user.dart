/// =============================================================================
/// User Entity
/// =============================================================================
/// 
/// Core domain entity representing a user in the system.
/// Contains user profile information and settings.
/// =============================================================================
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// User entity representing an authenticated user.
/// 
/// Contains profile information, preferences, and subscription status.
@freezed
class User with _$User {
  const User._();
  
  const factory User({
    /// Unique identifier (UUID)
    required String id,
    
    /// User's email address
    required String email,
    
    /// Display name
    required String name,
    
    /// Profile picture URL
    String? avatarUrl,
    
    /// Google account ID for OAuth
    String? googleId,
    
    /// User's timezone (e.g., 'America/New_York')
    @Default('UTC') String timezone,
    
    /// User settings
    @Default(UserSettings()) UserSettings settings,
    
    /// Subscription tier
    @Default(SubscriptionTier.free) SubscriptionTier subscriptionTier,
    
    /// Account creation timestamp
    required DateTime createdAt,
    
    /// Last update timestamp
    required DateTime updatedAt,
  }) = _User;
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  
  // ============= COMPUTED PROPERTIES =============
  
  /// First name extracted from full name.
  String get firstName => name.split(' ').first;
  
  /// User's initials for avatar fallback.
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
  
  /// Whether the user has a pro subscription.
  bool get isPro => subscriptionTier == SubscriptionTier.pro ||
                    subscriptionTier == SubscriptionTier.enterprise;
  
  /// Whether Google Calendar sync is connected.
  bool get hasCalendarSync => googleId != null;
}

/// User preferences and settings.
@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    /// Default view when opening the app
    @Default(DefaultView.list) DefaultView defaultView,
    
    /// Default reminder offset in minutes
    @Default(30) int defaultReminderMinutes,
    
    /// Whether to show completed tasks
    @Default(false) bool showCompletedTasks,
    
    /// Start of work day (hour, 0-23)
    @Default(9) int workDayStartHour,
    
    /// End of work day (hour, 0-23)
    @Default(17) int workDayEndHour,
    
    /// First day of week (1=Monday, 7=Sunday)
    @Default(1) int firstDayOfWeek,
    
    /// Whether to enable focus mode by default
    @Default(false) bool focusModeEnabled,
    
    /// Whether to sync with Google Calendar
    @Default(true) bool calendarSyncEnabled,
    
    /// Notification preferences
    @Default(NotificationSettings()) NotificationSettings notifications,
  }) = _UserSettings;
  
  factory UserSettings.fromJson(Map<String, dynamic> json) =>
    _$UserSettingsFromJson(json);
}

/// Notification preferences.
@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    /// Enable push notifications
    @Default(true) bool pushEnabled,
    
    /// Enable email notifications
    @Default(true) bool emailEnabled,
    
    /// Enable reminder notifications
    @Default(true) bool remindersEnabled,
    
    /// Enable daily summary
    @Default(true) bool dailySummaryEnabled,
    
    /// Hour to send daily summary (0-23)
    @Default(8) int dailySummaryHour,
    
    /// Enable weekly summary
    @Default(true) bool weeklySummaryEnabled,
    
    /// Day to send weekly summary (1-7)
    @Default(1) int weeklySummaryDay,
  }) = _NotificationSettings;
  
  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
    _$NotificationSettingsFromJson(json);
}

/// Default view options.
enum DefaultView {
  /// List view (traditional todo list)
  list,
  /// Calendar view (Google Calendar style)
  calendar,
  /// Board view (Kanban style)
  board,
  /// Focus view (one task at a time)
  focus,
}

/// Subscription tiers.
enum SubscriptionTier {
  /// Free tier with basic features
  free,
  /// Pro tier with advanced features
  pro,
  /// Enterprise tier for teams
  enterprise,
}
