/// =============================================================================
/// Auth Provider
/// =============================================================================
///
/// Manages authentication state using Riverpod.
/// Handles Google Sign-In and session management.
/// =============================================================================
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/config/environment.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/user.dart';

/// Authentication state.
class AuthState {
  /// Current authenticated user
  final User? user;

  /// Whether authentication is in progress
  final bool isLoading;

  /// Error message if authentication failed
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  /// Whether the user is authenticated.
  bool get isAuthenticated => user != null;

  /// Create loading state.
  AuthState copyWithLoading() => AuthState(
        user: user,
        isLoading: true,
        error: null,
      );

  /// Create success state.
  AuthState copyWithUser(User? user) => AuthState(
        user: user,
        isLoading: false,
        error: null,
      );

  /// Create error state.
  AuthState copyWithError(String error) => AuthState(
        user: user,
        isLoading: false,
        error: error,
      );
}

/// Provider for authentication state.
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>((ref) {
  return AuthNotifier(
    ref.watch(secureStorageProvider),
    ref.watch(apiClientProvider),
  );
});

/// Notifier for managing authentication state.
///
/// Handles:
/// - Google Sign-In flow
/// - Token storage and refresh
/// - User session management
/// - Logout
class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  final SecureStorage _secureStorage;
  final ApiClient _apiClient;
  final GoogleSignIn _googleSignIn;

  AuthNotifier(this._secureStorage, this._apiClient)
      : _googleSignIn = GoogleSignIn(
          // On Android, clientId should NOT be passed - it uses the OAuth client
          // configured in Google Cloud Console via SHA-1 + package name
          // On iOS/Web, we need to pass the client ID
          clientId:
              !kIsWeb && Platform.isAndroid ? null : Environment.googleClientId,
          // serverClientId is the Web Client ID - needed for backend token verification
          serverClientId: Environment.googleClientId,
          scopes: [
            'email',
            'profile',
            'https://www.googleapis.com/auth/calendar',
          ],
        ),
        super(const AsyncValue.data(AuthState(isLoading: true))) {
    // Check for existing session on initialization
    // Use Future.microtask to avoid blocking the main thread during startup
    Future.microtask(_checkAuthStatus);
  }

  /// Check if user is already authenticated.
  ///
  /// Called on app startup to restore session.
  Future<void> _checkAuthStatus() async {
    debugPrint('AuthNotifier: Starting auth check...');
    try {
      // Add timeout to prevent hanging on slow storage access
      final isLoggedIn = await _secureStorage.isLoggedIn
          .timeout(const Duration(seconds: 3), onTimeout: () => false);

      debugPrint('AuthNotifier: isLoggedIn = $isLoggedIn');

      if (isLoggedIn) {
        // For now, just mark as authenticated without API call
        // TODO: Uncomment when backend is available
        // final response = await _apiClient.get(ApiConstants.authMe);
        // final user = User.fromJson(response.data['data']);
        // state = AsyncValue.data(AuthState(user: user));

        // Temporary: Create a placeholder user until backend is ready
        state = const AsyncValue.data(AuthState());
      } else {
        state = const AsyncValue.data(AuthState());
      }
      debugPrint(
          'AuthNotifier: Auth check complete. isLoading=${state.valueOrNull?.isLoading}, isAuthenticated=${state.valueOrNull?.isAuthenticated}');
    } catch (e) {
      debugPrint('AuthNotifier: Auth check error: $e');
      // Token might be expired, clear and show login
      await _secureStorage.clearAll();
      state = const AsyncValue.data(AuthState());
    }
  }

  /// Sign in with Google.
  ///
  /// Opens the Google Sign-In flow and authenticates with the backend.
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.data(AuthState(isLoading: true));

    try {
      debugPrint('AuthNotifier: Starting Google Sign-In...');
      debugPrint(
          'AuthNotifier: serverClientId = ${Environment.googleClientId}');

      // Trigger Google Sign-In flow
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled sign-in
        debugPrint('AuthNotifier: User cancelled sign-in');
        state = const AsyncValue.data(AuthState());
        return;
      }

      debugPrint('AuthNotifier: Google user signed in: ${googleUser.email}');

      // Get authentication tokens from Google
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      debugPrint(
          'AuthNotifier: idToken = ${idToken != null ? "present (${idToken.length} chars)" : "NULL"}');
      debugPrint(
          'AuthNotifier: accessToken = ${accessToken != null ? "present" : "NULL"}');

      if (idToken == null) {
        throw Exception(
            'Failed to get ID token from Google. Make sure serverClientId (Web Client ID) is configured correctly.');
      }

      // Send ID token to backend for verification and JWT generation
      final response = await _apiClient.post(
        ApiConstants.authGoogleMobile,
        data: {
          'idToken': idToken,
        },
      );

      // Extract tokens from response
      final data = response.data['data'];
      final jwtAccessToken = data['accessToken'] as String;
      final jwtRefreshToken = data['refreshToken'] as String;
      final user = User.fromJson(data['user']);

      // Store tokens securely
      await _secureStorage.saveAccessToken(jwtAccessToken);
      await _secureStorage.saveRefreshToken(jwtRefreshToken);
      await _secureStorage.saveUserId(user.id);

      // Store Google tokens for Calendar API
      if (accessToken != null) {
        await _secureStorage.saveGoogleAccessToken(accessToken);
      }

      state = AsyncValue.data(AuthState(user: user));
    } catch (e) {
      state = AsyncValue.data(AuthState(
        error: 'Sign-in failed: ${e.toString()}',
      ));
    }
  }

  /// Sign out the current user.
  ///
  /// Clears all stored credentials and signs out of Google.
  Future<void> signOut() async {
    try {
      // Call backend logout endpoint
      await _apiClient.post(ApiConstants.authLogout);
    } catch (e) {
      // Continue with local logout even if API call fails
    }

    // Sign out of Google
    await _googleSignIn.signOut();

    // Clear all stored credentials
    await _secureStorage.clearAll();

    state = const AsyncValue.data(AuthState());
  }

  /// Refresh the access token.
  ///
  /// Called automatically by API client when token expires.
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _apiClient.post(
        ApiConstants.authRefresh,
        data: {'refreshToken': refreshToken},
      );

      final data = response.data['data'];
      await _secureStorage.saveAccessToken(data['accessToken']);
      if (data['refreshToken'] != null) {
        await _secureStorage.saveRefreshToken(data['refreshToken']);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get the current user.
  User? get currentUser => state.valueOrNull?.user;
}

/// Provider for current user (convenience).
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.user;
});

/// Provider for checking if user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.isAuthenticated ?? false;
});
