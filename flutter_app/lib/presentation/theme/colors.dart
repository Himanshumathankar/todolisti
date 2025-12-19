/// =============================================================================
/// App Colors
/// =============================================================================
/// 
/// Defines the color palette for the application.
/// Includes both light and dark theme colors.
/// 
/// Color System:
/// - Primary: Main brand color (blue)
/// - Secondary: Accent color (teal)
/// - Semantic: Success, Warning, Error, Info
/// - Surface: Backgrounds, cards, inputs
/// - Text: Primary, secondary, disabled
/// =============================================================================
library;

import 'package:flutter/material.dart';

/// Application color constants.
/// 
/// All colors are defined as static constants for consistency
/// and easy theming across the application.
class AppColors {
  AppColors._();
  
  // ============= BRAND COLORS =============
  
  /// Primary brand color - calming blue
  /// Represents productivity and focus
  static const Color primary = Color(0xFF3B82F6);
  
  /// Lighter variant of primary for dark theme
  static const Color primaryLight = Color(0xFF60A5FA);
  
  /// Darker variant of primary for emphasis
  static const Color primaryDark = Color(0xFF2563EB);
  
  /// Secondary accent color - teal
  /// Used for secondary actions and accents
  static const Color secondary = Color(0xFF14B8A6);
  
  /// Secondary light variant
  static const Color secondaryLight = Color(0xFF2DD4BF);
  
  // ============= SEMANTIC COLORS =============
  
  /// Success color - green
  /// Used for completed tasks, positive feedback
  static const Color success = Color(0xFF22C55E);
  
  /// Warning color - amber
  /// Used for due soon, attention needed
  static const Color warning = Color(0xFFF59E0B);
  
  /// Error color - red
  /// Used for overdue, validation errors, destructive actions
  static const Color error = Color(0xFFEF4444);
  
  /// Info color - sky blue
  /// Used for informational messages
  static const Color info = Color(0xFF0EA5E9);
  
  // ============= PRIORITY COLORS =============
  // Color-coded priority system for quick visual recognition
  
  /// No priority - gray
  static const Color priorityNone = Color(0xFF9CA3AF);
  
  /// Low priority - blue
  static const Color priorityLow = Color(0xFF3B82F6);
  
  /// Medium priority - yellow
  static const Color priorityMedium = Color(0xFFF59E0B);
  
  /// High priority - orange
  static const Color priorityHigh = Color(0xFFF97316);
  
  /// Urgent priority - red
  static const Color priorityUrgent = Color(0xFFEF4444);
  
  // ============= LIGHT THEME COLORS =============
  
  /// Light theme background
  static const Color backgroundLight = Color(0xFFF9FAFB);
  
  /// Light theme surface (cards, dialogs)
  static const Color surfaceLight = Color(0xFFFFFFFF);
  
  /// Light theme primary text
  static const Color textPrimaryLight = Color(0xFF111827);
  
  /// Light theme secondary text
  static const Color textSecondaryLight = Color(0xFF6B7280);
  
  /// Light theme disabled text
  static const Color textDisabledLight = Color(0xFF9CA3AF);
  
  /// Light theme border
  static const Color borderLight = Color(0xFFE5E7EB);
  
  /// Light theme divider
  static const Color dividerLight = Color(0xFFE5E7EB);
  
  // ============= DARK THEME COLORS =============
  
  /// Dark theme background
  static const Color backgroundDark = Color(0xFF111827);
  
  /// Dark theme surface (cards, dialogs)
  static const Color surfaceDark = Color(0xFF1F2937);
  
  /// Dark theme primary text
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  
  /// Dark theme secondary text
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  
  /// Dark theme disabled text
  static const Color textDisabledDark = Color(0xFF6B7280);
  
  /// Dark theme border
  static const Color borderDark = Color(0xFF374151);
  
  /// Dark theme divider
  static const Color dividerDark = Color(0xFF374151);
  
  // ============= TAG COLORS =============
  // Predefined colors for task tags and projects
  
  /// List of tag colors for user selection
  static const List<Color> tagColors = [
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFF59E0B), // Amber
    Color(0xFFEAB308), // Yellow
    Color(0xFF84CC16), // Lime
    Color(0xFF22C55E), // Green
    Color(0xFF14B8A6), // Teal
    Color(0xFF06B6D4), // Cyan
    Color(0xFF0EA5E9), // Sky
    Color(0xFF3B82F6), // Blue
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
    Color(0xFFA855F7), // Purple
    Color(0xFFD946EF), // Fuchsia
    Color(0xFFEC4899), // Pink
    Color(0xFFF43F5E), // Rose
  ];
  
  // ============= HELPER METHODS =============
  
  /// Get priority color by priority level (0-4).
  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return priorityLow;
      case 2:
        return priorityMedium;
      case 3:
        return priorityHigh;
      case 4:
        return priorityUrgent;
      default:
        return priorityNone;
    }
  }
  
  /// Get a readable text color for a given background.
  /// 
  /// Returns white for dark backgrounds, black for light backgrounds.
  static Color getContrastText(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? textPrimaryLight : textPrimaryDark;
  }
}
