/// =============================================================================
/// API Client
/// =============================================================================
/// 
/// Centralized HTTP client for all API requests. Uses Dio with interceptors
/// for authentication, logging, and error handling.
/// 
/// Features:
/// - Automatic token injection
/// - Token refresh on 401 errors
/// - Request/response logging (dev only)
/// - Retry logic for failed requests
/// - Consistent error transformation
/// =============================================================================
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../config/environment.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage.dart';

/// Logger instance for API client
final _logger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

/// Provider for the API client singleton.
final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient(secureStorage: secureStorage);
});

/// API client for making HTTP requests to the backend.
/// 
/// Handles authentication, error transformation, and logging.
/// All API calls should go through this client.
class ApiClient {
  /// Underlying Dio instance
  late final Dio _dio;
  
  /// Secure storage for tokens
  final SecureStorage secureStorage;
  
  /// Flag to prevent multiple simultaneous token refreshes
  bool _isRefreshing = false;
  
  /// Queue of requests waiting for token refresh
  final List<RequestOptions> _pendingRequests = [];

  ApiClient({required this.secureStorage}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: Environment.apiBaseUrl,
        connectTimeout: const Duration(seconds: Environment.requestTimeout),
        receiveTimeout: const Duration(seconds: Environment.requestTimeout),
        headers: {
          ApiConstants.contentTypeHeader: ApiConstants.contentTypeJson,
        },
      ),
    );
    
    _setupInterceptors();
  }
  
  /// Configure Dio interceptors for auth, logging, and errors.
  void _setupInterceptors() {
    // Auth interceptor - adds token to requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
    
    // Logging interceptor (development only)
    if (Environment.enableDebugLogging && Environment.isDevelopment) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (log) => _logger.d(log),
        ),
      );
    }
  }
  
  /// Request interceptor - adds authentication token.
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for auth endpoints
    if (_isAuthEndpoint(options.path)) {
      return handler.next(options);
    }
    
    // Get access token from secure storage
    final token = await secureStorage.getAccessToken();
    if (token != null) {
      options.headers[ApiConstants.authHeader] = 
        '${ApiConstants.bearerPrefix}$token';
    }
    
    // Add device ID for sync tracking
    final deviceId = await secureStorage.getDeviceId();
    options.headers[ApiConstants.deviceIdHeader] = deviceId;
      
    handler.next(options);
  }
  
  /// Response interceptor - handles successful responses.
  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    handler.next(response);
  }
  
  /// Error interceptor - handles errors and token refresh.
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized - try to refresh token
    if (error.response?.statusCode == 401 && 
        !_isAuthEndpoint(error.requestOptions.path)) {
      try {
        final retryResponse = await _handleTokenRefresh(error.requestOptions);
        return handler.resolve(retryResponse);
      } catch (e) {
        // Token refresh failed - propagate auth error
        return handler.reject(error);
      }
    }
    
    handler.reject(error);
  }
  
  /// Check if the endpoint is an auth endpoint (skip auth header).
  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/') && !path.contains('/auth/me');
  }
  
  /// Handle token refresh and retry the original request.
  /// 
  /// Uses a lock to prevent multiple simultaneous refresh requests.
  /// Queues pending requests to retry after refresh completes.
  Future<Response> _handleTokenRefresh(RequestOptions options) async {
    if (_isRefreshing) {
      // Another refresh is in progress, queue this request
      _pendingRequests.add(options);
      
      // Wait for refresh to complete
      await Future.delayed(const Duration(milliseconds: 100));
      while (_isRefreshing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // Retry with new token
      return _retryRequest(options);
    }
    
    _isRefreshing = true;
    
    try {
      // Get refresh token
      final refreshToken = await secureStorage.getRefreshToken();
      if (refreshToken == null) {
        throw AuthException.tokenExpired();
      }
      
      // Call refresh endpoint
      final response = await _dio.post(
        ApiConstants.authRefresh,
        data: {'refreshToken': refreshToken},
      );
      
      // Save new tokens
      final newAccessToken = response.data['accessToken'] as String;
      final newRefreshToken = response.data['refreshToken'] as String?;
      
      await secureStorage.saveAccessToken(newAccessToken);
      if (newRefreshToken != null) {
        await secureStorage.saveRefreshToken(newRefreshToken);
      }
      
      // Retry pending requests
      for (final pendingRequest in _pendingRequests) {
        _retryRequest(pendingRequest);
      }
      _pendingRequests.clear();
      
      // Retry original request
      return _retryRequest(options);
    } finally {
      _isRefreshing = false;
    }
  }
  
  /// Retry a request with the current token.
  Future<Response> _retryRequest(RequestOptions options) async {
    final token = await secureStorage.getAccessToken();
    options.headers[ApiConstants.authHeader] = 
      '${ApiConstants.bearerPrefix}$token';
    
    return _dio.fetch(options);
  }
  
  // ============= PUBLIC API METHODS =============
  
  /// Perform a GET request.
  /// 
  /// [path] - API endpoint path
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional request options
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _transformError(e);
    }
  }
  
  /// Perform a POST request.
  /// 
  /// [path] - API endpoint path
  /// [data] - Request body
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional request options
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _transformError(e);
    }
  }
  
  /// Perform a PUT request.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _transformError(e);
    }
  }
  
  /// Perform a PATCH request.
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _transformError(e);
    }
  }
  
  /// Perform a DELETE request.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _transformError(e);
    }
  }
  
  /// Transform Dio errors into app-specific exceptions.
  /// 
  /// Maps HTTP status codes and Dio error types to our exception hierarchy
  /// for consistent error handling throughout the app.
  AppException _transformError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException.timeout();
        
      case DioExceptionType.connectionError:
        return NetworkException.noConnection();
        
      case DioExceptionType.badResponse:
        return _handleResponseError(error.response!);
        
      case DioExceptionType.cancel:
        return const NetworkException(
          message: 'Request was cancelled',
          code: 'REQUEST_CANCELLED',
        );
        
      default:
        return NetworkException(
          message: error.message ?? 'An unexpected error occurred',
          code: 'UNKNOWN_ERROR',
          originalException: error,
        );
    }
  }
  
  /// Handle HTTP response errors based on status code.
  AppException _handleResponseError(Response response) {
    final statusCode = response.statusCode!;
    final data = response.data;
    final message = data is Map ? data['message'] as String? : null;
    
    switch (statusCode) {
      case 400:
        return ValidationException(
          message: message ?? 'Invalid request',
          code: 'BAD_REQUEST',
          fieldErrors: data is Map 
            ? (data['errors'] as Map<String, dynamic>?)?.cast<String, String>()
            : null,
        );
        
      case 401:
        return AuthException(
          message: message ?? 'Authentication required',
          code: 'UNAUTHORIZED',
        );
        
      case 403:
        return PermissionException(
          message: message ?? 'Access denied',
          code: 'FORBIDDEN',
        );
        
      case 404:
        return NotFoundException(
          message: message ?? 'Resource not found',
          code: 'NOT_FOUND',
        );
        
      case 409:
        return SyncException(
          message: message ?? 'Conflict detected',
          code: 'CONFLICT',
        );
        
      case 422:
        return ValidationException(
          message: message ?? 'Validation failed',
          code: 'VALIDATION_ERROR',
        );
        
      case 429:
        return const NetworkException(
          message: 'Too many requests. Please wait a moment.',
          code: 'RATE_LIMITED',
        );
        
      default:
        if (statusCode >= 500) {
          return NetworkException.serverError(statusCode);
        }
        return NetworkException(
          message: message ?? 'Request failed',
          code: 'HTTP_$statusCode',
          statusCode: statusCode,
        );
    }
  }
}
