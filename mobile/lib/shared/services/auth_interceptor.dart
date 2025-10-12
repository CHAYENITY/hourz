import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hourz/features/auth/models/auth.model.dart';
import 'package:hourz/shared/constants/api_endpoint.dart';
import 'package:hourz/shared/providers/token.provider.dart';

/// Auth Interceptor for automatic token refresh and authorization
class AuthInterceptor extends QueuedInterceptor {
  final Ref ref;
  final Dio dio;
  final Logger _logger = Logger();

  AuthInterceptor({required this.ref, required this.dio});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for login/register endpoints
    if (_shouldSkipAuth(options.path)) {
      _logger.d('⚪ Skipping auth for: ${options.path}');
      return handler.next(options);
    }

    try {
      final tokenNotifier = ref.read(tokenProvider.notifier);
      final token = ref.read(tokenProvider);

      // No token available
      if (token == null) {
        _logger.w('⚠️ No token available for: ${options.path}');
        return handler.next(options);
      }

      // Check if token needs refresh (expired or expiring soon)
      if (token.isAccessTokenExpired && !token.isRefreshTokenExpired) {
        _logger.d('🔄 Access token expired, refreshing...');
        try {
          await _refreshToken(token.refreshToken);
          final newToken = ref.read(tokenProvider);
          if (newToken != null) {
            options.headers['Authorization'] = newToken.authHeader;
            _logger.d('✅ Token refreshed, using new access token');
          }
        } catch (e) {
          _logger.e('❌ Token refresh failed: $e');
          // Token refresh failed, clear token and proceed without auth
          await tokenNotifier.clearToken();
          return handler.reject(
            DioException(
              requestOptions: options,
              error: 'Session expired. Please login again.',
              type: DioExceptionType.cancel,
            ),
          );
        }
      } else {
        // Token is valid, use it
        options.headers['Authorization'] = token.authHeader;
        _logger.d('🔵 Using access token for: ${options.path}');
      }

      return handler.next(options);
    } catch (e) {
      _logger.e('❌ Auth interceptor error: $e');
      return handler.next(options);
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized
    if (err.response?.statusCode == 401) {
      _logger.w('⚠️ 401 Unauthorized received');

      // Skip retry for login/register/refresh endpoints
      if (_shouldSkipAuth(err.requestOptions.path)) {
        return handler.next(err);
      }

      final token = ref.read(tokenProvider);

      // No token or refresh token expired
      if (token == null || token.isRefreshTokenExpired) {
        _logger.e('❌ No valid token, cannot retry');
        await ref.read(tokenProvider.notifier).clearToken();
        return handler.next(err);
      }

      try {
        _logger.d('🔄 Attempting to refresh token and retry request...');

        // Refresh token
        await _refreshToken(token.refreshToken);
        final newToken = ref.read(tokenProvider);

        if (newToken == null) {
          _logger.e('❌ Token refresh returned null');
          await ref.read(tokenProvider.notifier).clearToken();
          return handler.next(err);
        }

        // Retry original request with new token
        final options = err.requestOptions;
        options.headers['Authorization'] = newToken.authHeader;

        _logger.d('🔄 Retrying request with new token...');
        final response = await dio.fetch(options);
        return handler.resolve(response);
      } catch (e) {
        _logger.e('❌ Token refresh or retry failed: $e');
        await ref.read(tokenProvider.notifier).clearToken();
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  /// Refresh access token using refresh token
  Future<void> _refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '${ApiEndpoints.apiUrl}${ApiEndpoints.refreshToken}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $refreshToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data['data'] ?? response.data;
      final refreshResponse = RefreshTokenResponse.fromJson(data);

      // Update access token in storage
      await ref
          .read(tokenProvider.notifier)
          .updateAccessToken(refreshResponse.accessToken);

      _logger.d('✅ Token refreshed successfully');
    } catch (e) {
      _logger.e('❌ Token refresh failed: $e');
      rethrow;
    }
  }

  /// Check if endpoint should skip authentication
  bool _shouldSkipAuth(String path) {
    final skipPaths = [
      ApiEndpoints.login,
      ApiEndpoints.register,
      ApiEndpoints.refreshToken,
      ApiEndpoints.checkIdentifier,
    ];
    return skipPaths.any((skipPath) => path.contains(skipPath as Pattern));
  }
}
