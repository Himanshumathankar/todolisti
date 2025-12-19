/// =============================================================================
/// App Button Widget
/// =============================================================================
/// 
/// Reusable button component with consistent styling.
/// Supports multiple styles and states.
/// =============================================================================
library;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// Button style variants.
enum AppButtonStyle {
  /// Primary filled button
  primary,
  /// Secondary outlined button
  secondary,
  /// Text-only button
  text,
  /// Danger/destructive button
  danger,
}

/// Reusable button component.
/// 
/// Features:
/// - Multiple style variants
/// - Loading state with spinner
/// - Icon support
/// - Full-width option
class AppButton extends StatelessWidget {
  /// Button label text.
  final String label;
  
  /// Optional leading icon.
  final IconData? icon;
  
  /// Button style variant.
  final AppButtonStyle style;
  
  /// Callback when button is pressed. Null disables the button.
  final VoidCallback? onPressed;
  
  /// Whether to show loading indicator.
  final bool isLoading;
  
  /// Whether button should fill available width.
  final bool isFullWidth;
  
  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.style = AppButtonStyle.primary,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget child = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getLoadingColor(),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );
    
    switch (style) {
      case AppButtonStyle.primary:
        return _wrapFullWidth(
          ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          ),
        );
        
      case AppButtonStyle.secondary:
        return _wrapFullWidth(
          OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          ),
        );
        
      case AppButtonStyle.text:
        return _wrapFullWidth(
          TextButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          ),
        );
        
      case AppButtonStyle.danger:
        return _wrapFullWidth(
          ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: child,
          ),
        );
    }
  }
  
  Widget _wrapFullWidth(Widget button) {
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    return button;
  }
  
  Color _getLoadingColor() {
    switch (style) {
      case AppButtonStyle.primary:
      case AppButtonStyle.danger:
        return Colors.white;
      case AppButtonStyle.secondary:
      case AppButtonStyle.text:
        return AppColors.primary;
    }
  }
}
