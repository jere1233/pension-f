///home/hp/JERE/pension-frontend/lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_helper.dart';

class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_getAuthInterceptor());
    _dio.interceptors.add(_getLoggerInterceptor());
  }

  // Get Dio instance
  Dio get dio => _dio;

  // Auth Interceptor
  InterceptorsWrapper _getAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Skip auth header for unauthenticated endpoints
        final unauthEndpoints = [
          '/api/auth/login',
          '/api/auth/login/otp',
          '/api/auth/register',
          '/api/auth/forgot-password',
          '/api/auth/forgot-password/verify',
          '/api/auth/resend-otp',
          '/api/auth/reset-pin',
          '/api/auth/reset-pin/verify',
          '/api/health',
          '/api/users/user-names-by-phone',
          '/api/auth/ussd-login',
        ];

        final isUnauthEndpoint = unauthEndpoints.any((endpoint) => options.path.contains(endpoint));
        
        // Add token to headers if available and not an unauth endpoint
        if (!isUnauthEndpoint) {
          final token = await SecureStorageHelper.read('auth_token');
          print('DEBUG: Auth token for ${options.path}: ${token != null ? 'present' : 'null'}');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print('DEBUG: Added auth header for ${options.path}');
          } else {
            print('DEBUG: No auth token found for ${options.path}');
          }
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        // Handle 401 Unauthorized - Token expired
        if (error.response?.statusCode == 401) {
          // Try to refresh token
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the request
            return handler.resolve(await _retry(error.requestOptions));
          } else {
            // Logout user
            await SecureStorageHelper.deleteAll();
            // Navigate to login screen (implement navigation)
          }
        }
        return handler.next(error);
      },
    );
  }

  // Logger Interceptor
  PrettyDioLogger _getLoggerInterceptor() {
    return PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    );
  }

  // Refresh Token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await SecureStorageHelper.read('refresh_token');
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];
        
        await SecureStorageHelper.write('auth_token', newToken);
        await SecureStorageHelper.write('refresh_token', newRefreshToken);
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Retry Request
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST Request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT Request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE Request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH Request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error Handler
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'] ?? 'Something went wrong';
        
        switch (statusCode) {
          case 400:
            return Exception('Bad request: $message');
          case 401:
            return Exception('Unauthorized: $message');
          case 403:
            return Exception('Forbidden: $message');
          case 404:
            return Exception('Not found: $message');
          case 500:
            return Exception('Internal server error: $message');
          default:
            return Exception('Error $statusCode: $message');
        }
      
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      
      case DioExceptionType.unknown:
        if (error.error.toString().contains('SocketException')) {
          return Exception('No internet connection');
        }
        return Exception('Unexpected error occurred');
      
      default:
        return Exception('Something went wrong');
    }
  }
}
