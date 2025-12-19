/// =============================================================================
/// Secure Storage
/// =============================================================================
/// 
/// Provides secure storage for sensitive data like tokens and credentials.
/// Uses flutter_secure_storage which encrypts data on the device.
/// 
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences or Keystore
/// - Windows/Linux/macOS: Encrypted file storage
/// =============================================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Provider for secure storage singleton.
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

/// Secure storage for sensitive data.
/// 
/// All data is encrypted before being stored on the device.
/// Use this for tokens, passwords, and other sensitive information.
class SecureStorage {
  /// Underlying secure storage instance
  final FlutterSecureStorage _storage;
  
  // Storage keys
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyDeviceId = 'device_id';
  static const String _keyUserId = 'user_id';
  static const String _keyGoogleAccessToken = 'google_access_token';
  static const String _keyGoogleRefreshToken = 'google_refresh_token';
  
  SecureStorage() : _storage = const FlutterSecureStorage(
    // Android-specific options for enhanced security
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    // iOS-specific options
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  // ============= ACCESS TOKEN =============
  
  /// Save the JWT access token.
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }
  
  /// Get the JWT access token.
  /// 
  /// Returns null if no token is stored.
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }
  
  /// Delete the access token.
  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _keyAccessToken);
  }
  
  // ============= REFRESH TOKEN =============
  
  /// Save the refresh token.
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }
  
  /// Get the refresh token.
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }
  
  /// Delete the refresh token.
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _keyRefreshToken);
  }
  
  // ============= DEVICE ID =============
  
  /// Get or generate a unique device ID.
  /// 
  /// The device ID is used to identify this device for sync purposes.
  /// It's generated once and persisted for the lifetime of the app install.
  Future<String> getDeviceId() async {
    var deviceId = await _storage.read(key: _keyDeviceId);
    
    if (deviceId == null) {
      // Generate a new device ID
      deviceId = const Uuid().v4();
      await _storage.write(key: _keyDeviceId, value: deviceId);
    }
    
    return deviceId;
  }
  
  // ============= USER ID =============
  
  /// Save the current user's ID.
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }
  
  /// Get the current user's ID.
  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }
  
  /// Delete the user ID.
  Future<void> deleteUserId() async {
    await _storage.delete(key: _keyUserId);
  }
  
  // ============= GOOGLE TOKENS =============
  
  /// Save Google OAuth access token.
  /// 
  /// Used for Google Calendar API access.
  Future<void> saveGoogleAccessToken(String token) async {
    await _storage.write(key: _keyGoogleAccessToken, value: token);
  }
  
  /// Get Google OAuth access token.
  Future<String?> getGoogleAccessToken() async {
    return await _storage.read(key: _keyGoogleAccessToken);
  }
  
  /// Save Google OAuth refresh token.
  Future<void> saveGoogleRefreshToken(String token) async {
    await _storage.write(key: _keyGoogleRefreshToken, value: token);
  }
  
  /// Get Google OAuth refresh token.
  Future<String?> getGoogleRefreshToken() async {
    return await _storage.read(key: _keyGoogleRefreshToken);
  }
  
  // ============= UTILITY METHODS =============
  
  /// Check if the user is logged in.
  /// 
  /// Returns true if an access token exists.
  Future<bool> get isLoggedIn async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
  
  /// Clear all stored credentials.
  /// 
  /// Called on logout to remove all sensitive data.
  Future<void> clearAll() async {
    await deleteAccessToken();
    await deleteRefreshToken();
    await deleteUserId();
    await _storage.delete(key: _keyGoogleAccessToken);
    await _storage.delete(key: _keyGoogleRefreshToken);
    // Note: We keep the device ID even after logout
  }
  
  /// Delete all data including device ID.
  /// 
  /// Use this for complete app reset.
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
