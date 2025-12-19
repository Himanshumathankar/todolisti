/// =============================================================================
/// App Typography
/// =============================================================================
/// 
/// Defines the typography system for the application.
/// Based on Material 3 type scale with custom adjustments for readability.
/// 
/// Font: Inter - A highly readable sans-serif optimized for screens.
/// =============================================================================
library;

import 'package:flutter/material.dart';

import 'colors.dart';

/// Application typography configuration.
/// 
/// Provides consistent text styles across the application.
class AppTypography {
  AppTypography._();
  
  /// Primary font family
  static const String fontFamily = 'Inter';
  
  // ============= FONT WEIGHTS =============
  
  /// Regular weight (400)
  static const FontWeight regular = FontWeight.w400;
  
  /// Medium weight (500)
  static const FontWeight medium = FontWeight.w500;
  
  /// Semi-bold weight (600)
  static const FontWeight semiBold = FontWeight.w600;
  
  /// Bold weight (700)
  static const FontWeight bold = FontWeight.w700;
  
  // ============= TEXT THEME (LIGHT) =============
  
  /// Light theme text styles.
  static TextTheme get textTheme => const TextTheme(
    // Display styles - for hero text
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 57,
      fontWeight: regular,
      letterSpacing: -0.25,
      height: 1.12,
      color: AppColors.textPrimaryLight,
    ),
    displayMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 45,
      fontWeight: regular,
      letterSpacing: 0,
      height: 1.16,
      color: AppColors.textPrimaryLight,
    ),
    displaySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 36,
      fontWeight: regular,
      letterSpacing: 0,
      height: 1.22,
      color: AppColors.textPrimaryLight,
    ),
    
    // Headline styles - for section headers
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      fontWeight: semiBold,
      letterSpacing: 0,
      height: 1.25,
      color: AppColors.textPrimaryLight,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      fontWeight: semiBold,
      letterSpacing: 0,
      height: 1.29,
      color: AppColors.textPrimaryLight,
    ),
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: semiBold,
      letterSpacing: 0,
      height: 1.33,
      color: AppColors.textPrimaryLight,
    ),
    
    // Title styles - for card titles, app bar
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 22,
      fontWeight: semiBold,
      letterSpacing: 0,
      height: 1.27,
      color: AppColors.textPrimaryLight,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: medium,
      letterSpacing: 0.15,
      height: 1.5,
      color: AppColors.textPrimaryLight,
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: medium,
      letterSpacing: 0.1,
      height: 1.43,
      color: AppColors.textPrimaryLight,
    ),
    
    // Body styles - for main content
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: regular,
      letterSpacing: 0.5,
      height: 1.5,
      color: AppColors.textPrimaryLight,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: regular,
      letterSpacing: 0.25,
      height: 1.43,
      color: AppColors.textPrimaryLight,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: regular,
      letterSpacing: 0.4,
      height: 1.33,
      color: AppColors.textSecondaryLight,
    ),
    
    // Label styles - for buttons, chips
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: medium,
      letterSpacing: 0.1,
      height: 1.43,
      color: AppColors.textPrimaryLight,
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: medium,
      letterSpacing: 0.5,
      height: 1.33,
      color: AppColors.textPrimaryLight,
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: medium,
      letterSpacing: 0.5,
      height: 1.45,
      color: AppColors.textSecondaryLight,
    ),
  );
  
  // ============= TEXT THEME (DARK) =============
  
  /// Dark theme text styles.
  static TextTheme get textThemeDark => TextTheme(
    displayLarge: textTheme.displayLarge?.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    displayMedium: textTheme.displayMedium?.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    displaySmall: textTheme.displaySmall?.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    headlineLarge: textTheme.headlineLarge?.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    headlineMedium: textTheme.headlineMedium?.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    headlineSmall: textTheme.headlineSmall?.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    titleLarge: textTheme.titleLarge?.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    titleMedium: textTheme.titleMedium?.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    titleSmall: textTheme.titleSmall?.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    bodyLarge: textTheme.bodyLarge?.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    bodyMedium: textTheme.bodyMedium?.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    bodySmall: textTheme.bodySmall?.copyWith(
      color: AppColors.textSecondaryDark,
    ),
    labelLarge: textTheme.labelLarge?.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    labelMedium: textTheme.labelMedium?.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    labelSmall: textTheme.labelSmall?.copyWith(
      color: AppColors.textSecondaryDark,
    ),
  );
}
