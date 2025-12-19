/// =============================================================================
/// Theme Provider
/// =============================================================================
/// 
/// Manages the application's theme mode (light, dark, system).
/// Persists the user's theme preference across app restarts.
/// =============================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key for storing theme mode in SharedPreferences.
const String _themeModeKey = 'theme_mode';

/// Provider for the current theme mode.
/// 
/// Watches this provider to reactively update the UI when theme changes.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

/// Notifier for managing theme mode state.
/// 
/// Handles loading, saving, and updating the theme mode.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }
  
  /// Load the saved theme mode from persistent storage.
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeModeKey);
      
      if (themeModeString != null) {
        state = _themeModeFromString(themeModeString);
      }
    } catch (e) {
      // If loading fails, keep the default (system)
      debugPrint('Failed to load theme mode: $e');
    }
  }
  
  /// Set the theme mode and persist it.
  /// 
  /// [mode] - The new theme mode to set.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, _themeModeToString(mode));
    } catch (e) {
      debugPrint('Failed to save theme mode: $e');
    }
  }
  
  /// Toggle between light and dark mode.
  /// 
  /// If currently in system mode, will switch to light mode.
  Future<void> toggleTheme() async {
    switch (state) {
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.light);
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
    }
  }
  
  /// Convert ThemeMode to string for storage.
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
  
  /// Convert string to ThemeMode.
  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
