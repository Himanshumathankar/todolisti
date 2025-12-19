/// =============================================================================
/// UI Constants
/// =============================================================================
/// 
/// Defines all UI-related constants for consistent styling across the app.
/// Includes spacing, sizing, border radius, and other visual properties.
/// =============================================================================
library;

import 'package:flutter/material.dart';

/// UI spacing, sizing, and visual constants.
class UIConstants {
  UIConstants._();
  
  // ============= SPACING =============
  // Based on 4px grid system
  
  /// Extra small spacing (4px)
  static const double spacingXs = 4.0;
  
  /// Small spacing (8px)
  static const double spacingSm = 8.0;
  
  /// Medium spacing (16px) - most common
  static const double spacingMd = 16.0;
  
  /// Large spacing (24px)
  static const double spacingLg = 24.0;
  
  /// Extra large spacing (32px)
  static const double spacingXl = 32.0;
  
  /// XXL spacing (48px) - for major sections
  static const double spacingXxl = 48.0;
  
  // ============= PADDING =============
  
  /// Standard screen padding
  static const EdgeInsets screenPadding = EdgeInsets.all(spacingMd);
  
  /// Card content padding
  static const EdgeInsets cardPadding = EdgeInsets.all(spacingMd);
  
  /// List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: spacingMd,
    vertical: spacingSm,
  );
  
  /// Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: spacingLg,
    vertical: spacingSm,
  );
  
  // ============= BORDER RADIUS =============
  
  /// Small border radius (4px)
  static const double radiusSm = 4.0;
  
  /// Medium border radius (8px) - for cards
  static const double radiusMd = 8.0;
  
  /// Large border radius (12px) - for modals
  static const double radiusLg = 12.0;
  
  /// Extra large border radius (16px) - for buttons
  static const double radiusXl = 16.0;
  
  /// Full/circular border radius
  static const double radiusFull = 999.0;
  
  /// Standard card border radius
  static const BorderRadius cardBorderRadius = BorderRadius.all(
    Radius.circular(radiusMd),
  );
  
  /// Standard button border radius
  static const BorderRadius buttonBorderRadius = BorderRadius.all(
    Radius.circular(radiusXl),
  );
  
  // ============= SIZES =============
  
  /// Icon size - small
  static const double iconSizeSm = 16.0;
  
  /// Icon size - medium (default)
  static const double iconSizeMd = 24.0;
  
  /// Icon size - large
  static const double iconSizeLg = 32.0;
  
  /// Avatar size - small
  static const double avatarSizeSm = 32.0;
  
  /// Avatar size - medium
  static const double avatarSizeMd = 40.0;
  
  /// Avatar size - large
  static const double avatarSizeLg = 56.0;
  
  /// Minimum touch target size (accessibility)
  static const double minTouchTarget = 48.0;
  
  /// Task card height
  static const double taskCardHeight = 72.0;
  
  /// AppBar height
  static const double appBarHeight = 56.0;
  
  /// Bottom navigation bar height
  static const double bottomNavHeight = 80.0;
  
  /// FAB size
  static const double fabSize = 56.0;
  
  // ============= ELEVATION =============
  
  /// No elevation
  static const double elevationNone = 0.0;
  
  /// Low elevation (cards)
  static const double elevationLow = 2.0;
  
  /// Medium elevation (modals)
  static const double elevationMed = 4.0;
  
  /// High elevation (dialogs)
  static const double elevationHigh = 8.0;
  
  // ============= OPACITY =============
  
  /// Disabled element opacity
  static const double opacityDisabled = 0.38;
  
  /// Subtle element opacity
  static const double opacitySubtle = 0.6;
  
  /// Overlay opacity
  static const double opacityOverlay = 0.5;
  
  // ============= BREAKPOINTS =============
  // For responsive layouts
  
  /// Mobile breakpoint (< 600px)
  static const double breakpointMobile = 600.0;
  
  /// Tablet breakpoint (< 900px)
  static const double breakpointTablet = 900.0;
  
  /// Desktop breakpoint (< 1200px)
  static const double breakpointDesktop = 1200.0;
  
  // ============= ANIMATION DURATIONS =============
  
  /// Fast animation (150ms)
  static const Duration durationFast = Duration(milliseconds: 150);
  
  /// Medium animation (300ms)
  static const Duration durationMedium = Duration(milliseconds: 300);
  
  /// Slow animation (500ms)
  static const Duration durationSlow = Duration(milliseconds: 500);
}
