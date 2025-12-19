/// =============================================================================
/// Application Failures
/// =============================================================================
/// 
/// Failures represent expected error states that can occur during use cases.
/// Unlike exceptions (which are thrown), failures are returned as values
/// using functional programming patterns (Either<Failure, Success>).
/// 
/// This approach from Clean Architecture allows for:
/// - Explicit error handling in business logic
/// - No unexpected exceptions in domain layer
/// - Easier testing of error scenarios
/// =============================================================================
library;

import 'package:equatable/equatable.dart';

/// Base failure class for all domain failures.
/// 
/// Uses [Equatable] for value comparison in tests and business logic.
/// Each failure type should extend this class.
sealed class Failure extends Equatable {
  /// Human-readable error message
  final String message;
  
  /// Error code for programmatic handling
  final String? code;
  
  const Failure({
    required this.message,
    this.code,
  });
  
  @override
  List<Object?> get props => [message, code];
}

/// Failure representing a server/API error.
class ServerFailure extends Failure {
  /// HTTP status code if available
  final int? statusCode;
  
  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
  });
  
  /// Factory for generic server error
  factory ServerFailure.generic() => const ServerFailure(
    message: 'An error occurred on the server. Please try again.',
    code: 'SERVER_ERROR',
  );
  
  @override
  List<Object?> get props => [...super.props, statusCode];
}

/// Failure representing a network/connection error.
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
  });
  
  /// Factory for no connection
  factory NetworkFailure.noConnection() => const NetworkFailure(
    message: 'No internet connection. Please check your network.',
    code: 'NO_CONNECTION',
  );
  
  /// Factory for timeout
  factory NetworkFailure.timeout() => const NetworkFailure(
    message: 'Connection timed out. Please try again.',
    code: 'TIMEOUT',
  );
}

/// Failure representing an authentication error.
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });
  
  /// Factory for expired session
  factory AuthFailure.sessionExpired() => const AuthFailure(
    message: 'Your session has expired. Please sign in again.',
    code: 'SESSION_EXPIRED',
  );
  
  /// Factory for invalid credentials
  factory AuthFailure.invalidCredentials() => const AuthFailure(
    message: 'Invalid email or password.',
    code: 'INVALID_CREDENTIALS',
  );
  
  /// Factory for Google sign in failed
  factory AuthFailure.googleSignInFailed() => const AuthFailure(
    message: 'Google sign in failed. Please try again.',
    code: 'GOOGLE_SIGN_IN_FAILED',
  );
  
  /// Factory for unauthorized
  factory AuthFailure.unauthorized() => const AuthFailure(
    message: 'You are not authorized to perform this action.',
    code: 'UNAUTHORIZED',
  );
}

/// Failure representing a local storage/cache error.
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });
  
  /// Factory for cache not found
  factory CacheFailure.notFound() => const CacheFailure(
    message: 'Data not found in local storage.',
    code: 'CACHE_NOT_FOUND',
  );
  
  /// Factory for cache write error
  factory CacheFailure.writeError() => const CacheFailure(
    message: 'Failed to save data locally.',
    code: 'CACHE_WRITE_ERROR',
  );
}

/// Failure representing validation errors.
class ValidationFailure extends Failure {
  /// Map of field names to error messages
  final Map<String, String>? fieldErrors;
  
  const ValidationFailure({
    required super.message,
    super.code,
    this.fieldErrors,
  });
  
  /// Factory for required field
  factory ValidationFailure.required(String field) => ValidationFailure(
    message: '$field is required',
    code: 'REQUIRED_FIELD',
    fieldErrors: {field: '$field is required'},
  );
  
  /// Factory for invalid format
  factory ValidationFailure.invalidFormat(String field, String format) =>
    ValidationFailure(
      message: '$field must be in $format format',
      code: 'INVALID_FORMAT',
      fieldErrors: {field: 'Invalid format'},
    );
  
  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// Failure representing a resource not found.
class NotFoundFailure extends Failure {
  /// The type of resource not found
  final String? resourceType;
  
  /// The ID of the resource
  final String? resourceId;
  
  const NotFoundFailure({
    required super.message,
    super.code,
    this.resourceType,
    this.resourceId,
  });
  
  /// Factory for task not found
  factory NotFoundFailure.task(String id) => NotFoundFailure(
    message: 'Task not found',
    code: 'TASK_NOT_FOUND',
    resourceType: 'task',
    resourceId: id,
  );
  
  @override
  List<Object?> get props => [...super.props, resourceType, resourceId];
}

/// Failure representing a permission/access error.
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
  });
  
  /// Factory for insufficient permissions
  factory PermissionFailure.insufficient() => const PermissionFailure(
    message: 'You do not have permission to perform this action.',
    code: 'INSUFFICIENT_PERMISSIONS',
  );
}

/// Failure representing a sync/conflict error.
class SyncFailure extends Failure {
  const SyncFailure({
    required super.message,
    super.code,
  });
  
  /// Factory for sync conflict
  factory SyncFailure.conflict() => const SyncFailure(
    message: 'Sync conflict detected. Please resolve manually.',
    code: 'SYNC_CONFLICT',
  );
  
  /// Factory for sync failed
  factory SyncFailure.failed() => const SyncFailure(
    message: 'Sync failed. Will retry automatically.',
    code: 'SYNC_FAILED',
  );
}
