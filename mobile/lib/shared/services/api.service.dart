import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hourz/shared/index.dart';

/// Simple API Service for basic CRUD operations
class ApiService {
  /// Handle DioException and convert to ErrorResponse
  ErrorResponse _handleError(DioException error) {
    try {
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic>) {
        return ErrorResponse.fromJson(responseData);
      } else if (responseData is String) {
        return ErrorResponse(
          statusCode: error.response?.statusCode,
          message: responseData,
        );
      } else {
        return ErrorResponse(
          statusCode: error.response?.statusCode,
          message: error.message ?? 'Unknown error',
        );
      }
    } catch (e) {
      return ErrorResponse(
        statusCode: error.response?.statusCode,
        message: error.message ?? 'Unknown error',
      );
    }
  }

  late final Dio _dio;
  final Logger _logger = Logger();
  final Ref? _ref; // For auth interceptor

  ApiService({Ref? ref}) : _ref = ref {
    try {
      _dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.apiUrl,
          connectTimeout: AppConfig.apiTimeout,
          receiveTimeout: AppConfig.apiTimeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Add logging interceptor
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            _logger.d('🔵 ${options.method} ${options.baseUrl}${options.path}');
            handler.next(options);
          },
          onResponse: (response, handler) {
            _logger.d(
              '🟢 ${response.statusCode} ${response.requestOptions.path}',
            );
            handler.next(response);
          },
          onError: (error, handler) {
            _logger.e(
              '🔴 ${error.response?.statusCode} ${error.requestOptions.path}: ${error.message}',
            );
            handler.next(error);
          },
        ),
      );

      // Add auth interceptor (if ref is provided)
      if (_ref != null) {
        _dio.interceptors.add(AuthInterceptor(ref: _ref, dio: _dio));
        _logger.d('✅ Auth interceptor added');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// GET - Fetch list
  Future<List<T>> getList<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParams);
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((item) => fromJson(item)).toList();
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  /// GET - Fetch by ID
  Future<T> getById<T>(
    String endpoint,
    String id,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final path = id.isEmpty ? endpoint : '$endpoint/$id';
      final response = await _dio.get(path, queryParameters: queryParams);
      final Map<String, dynamic> data = response.data['data'] ?? response.data;
      return fromJson(data);
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  /// GET - Single resource (no ID needed)
  Future<T> get<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParams);
      final Map<String, dynamic> data = response.data['data'] ?? response.data;
      return fromJson(data);
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  /// POST - Create
  Future<T> create<T>(
    String endpoint,
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      final Map<String, dynamic> responseData =
          response.data['data'] ?? response.data;
      return fromJson(responseData);
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  /// POST - Multipart FormData (for file upload, images, etc.)
  Future<T> createFormData<T>(
    String endpoint,
    Map<String, dynamic> fields, {
    Map<String, String>? fileFields, // key: field name, value: file path
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final formMap = Map<String, dynamic>.from(fields);
      if (fileFields != null) {
        for (final entry in fileFields.entries) {
          formMap[entry.key] = await MultipartFile.fromFile(entry.value);
        }
      }
      final formData = FormData.fromMap(formMap);
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final Map<String, dynamic> responseData =
          response.data['data'] ?? response.data;
      return fromJson(responseData);
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  /// POST - Form URL Encoded (for OAuth2, login, etc.)
  Future<T> postFormUrlEncoded<T>(
    String endpoint,
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final Map<String, dynamic> responseData =
          response.data['data'] ?? response.data;
      return fromJson(responseData);
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  /// PUT - Update
  Future<T> update<T>(
    String endpoint,
    String id,
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _dio.put('$endpoint/$id', data: data);
      final Map<String, dynamic> responseData =
          response.data['data'] ?? response.data;
      return fromJson(responseData);
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }

  /// DELETE
  Future<void> delete(String endpoint, String id) async {
    try {
      await _dio.delete('$endpoint/$id');
    } on DioException catch (error) {
      throw _handleError(error);
    }
  }
}

/// Provider for SimpleApiService
final apiProvider = Provider<ApiService>((ref) => ApiService(ref: ref));
