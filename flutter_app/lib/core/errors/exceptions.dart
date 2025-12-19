/// =============================================================================
/// Application Exceptions
/// =============================================================================
/// 
/// Defines custom exception types for error handling throughout the app.
/// Each exception type represents a specific category of error that can
/// be handled differently in the UI or logging.
/// =============================================================================
library;

/// Base exception class for all app-specific exceptions.
/// 
/// All custom exceptions should extend this class to enable
/// consistent error handling across the application.
sealed class AppException implements Exception {
  /// Human-readable error message
  final String message;
  
  /// Optional error code for categorization
  final String? code;
  
  /// Original exception that caused this error
  final dynamic originalException;
  
  /// Stack trace from the original error
  final StackTrace? stackTrace;
  
  const AppException({
    required this.message,
    this.code,
    this.originalException,
    this.stackTrace,
  });
  
  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Exception thrown when a network request fails.
/// 
/// This includes connection errors, timeouts, and server errors.
class NetworkException extends AppException {
  /// HTTP status code if available
  final int? statusCode;
  
  const NetworkException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
    this.statusCode,
  });
  
  /// Factory for timeout errors
  factory NetworkException.timeout() => const NetworkException(
    message: 'Request timed out. Please check your connection.',
    code: 'TIMEOUT',
  );
  
  /// Factory for no internet connection
  factory NetworkException.noConnection() => const NetworkException(
    message: 'No internet connection. Please check your network.',
    code: 'NO_CONNECTION',
  );
  
  /// Factory for server errors (5xx)
  factory NetworkException.serverError([int? statusCode]) => NetworkException(
    message: 'Server error. Please try again later.',
    code: 'SERVER_ERROR',
    statusCode: statusCode,
  );
  
  @override
  String toString() => 'NetworkException: $message (status: $statusCode)';
}

/// Exception thrown when authentication fails.
/// 
/// Includes expired tokens, invalid credentials, and unauthorized access.
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });
  
  /// Factory for expired token
  factory AuthException.tokenExpired() => const AuthException(
    message: 'Your session has expired. Please sign in again.',
    code: 'TOKEN_EXPIRED',
  );
  
  /// Factory for invalid credentials
  factory AuthException.invalidCredentials() => const AuthException(
    message: 'Invalid email or password.',
    code: 'INVALID_CREDENTIALS',
  );
  
  /// Factory for unauthorized access
  factory AuthException.unauthorized() => const AuthException(
    message: 'You are not authorized to perform this action.',
    code: 'UNAUTHORIZED',
  );
  
  /// Factory for account disabled
  factory AuthException.accountDisabled() => const AuthException(
    message: 'Your account has been disabled.',
    code: 'ACCOUNT_DISABLED',
  );
}

/// Exception thrown when validation fails.
/// 
/// Used for form validation errors and input validation.
class ValidationException extends AppException {
  /// Map of field names to error messages
  final Map<String, String>? fieldErrors;
  
  const ValidationException({
    required super.message,
    super.code,
    this.fieldErrors,
  });
  
  /// Factory for single field validation error
  factory ValidationException.field(String field, String error) =>
    ValidationException(
      message: error,
      code: 'VALIDATION_ERROR',
      fieldErrors: {field: error},
    );
}

/// Exception thrown when a requested resource is not found.
class NotFoundException extends AppException {
  /// Type of resource that was not found
  final String? resourceType;
  
  /// ID of the resource that was not found
  final String? resourceId;
  
  const NotFoundException({
    required super.message,
    super.code,
    this.resourceType,
    this.resourceId,
  });
  
  /// Factory for task not found
  factory NotFoundException.task(String id) => NotFoundException(
    message: 'Task not found',
    code: 'TASK_NOT_FOUND',
    resourceType: 'task',
    resourceId: id,
  );
  
  /// Factory for project not found
  factory NotFoundException.project(String id) => NotFoundException(
    message: 'Project not found',
    code: 'PROJECT_NOT_FOUND',
    resourceType: 'project',
    resourceId: id,
  );
}

/// Exception thrown when there's a permission/access issue.
class PermissionException extends AppException {
  /// The action that was denied
  final String? action;
  
  /// The resource that access was denied to
  final String? resource;
  
  const PermissionException({
    required super.message,
    super.code,
    this.action,
    this.resource,
  });
  
  /// Factory for insufficient permissions
  factory PermissionException.insufficientPermissions() =>
    const PermissionException(
      message: 'You do not have permission to perform this action.',
      code: 'INSUFFICIENT_PERMISSIONS',
    );
}

/// Exception thrown when there's a sync conflict.
class SyncException extends AppException {
  /// The conflicting local version
  final dynamic localVersion;
  
  /// The conflicting remote version
  final dynamic remoteVersion;
  
  const SyncException({
    required super.message,
    super.code,
    this.localVersion,
    this.remoteVersion,
  });
  
  /// Factory for sync conflict
  factory SyncException.conflict({
    dynamic localVersion,
    dynamic remoteVersion,
  }) => SyncException(
    message: 'Sync conflict detected. Please resolve manually.',
    code: 'SYNC_CONFLICT',
    localVersion: localVersion,
    remoteVersion: remoteVersion,
  );
  
  /// Factory for sync failed
  factory SyncException.failed([String? reason]) => SyncException(
    message: reason ?? 'Sync failed. Will retry automatically.',
    code: 'SYNC_FAILED',
  );
}

/// Exception thrown for local storage/database errors.
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });
  
  /// Factory for database error
  factory StorageException.database([String? details]) => StorageException(
    message: details ?? 'Database error occurred.',
    code: 'DATABASE_ERROR',
  );
  
  /// Factory for storage full
  factory StorageException.storageFull() => const StorageException(
    message: 'Device storage is full.',
    code: 'STORAGE_FULL',
  );
}

/// Exception thrown for cache-related errors.
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
  });
  
  /// Factory for cache miss
  factory CacheException.notFound() => const CacheException(
    message: 'Data not found in cache.',
    code: 'CACHE_MISS',
  );
  
  /// Factory for cache expired
  factory CacheException.expired() => const CacheException(
    message: 'Cache data has expired.',
    code: 'CACHE_EXPIRED',
  );
}
