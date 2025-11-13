import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:cermatify/app/data/constants/api_constant.dart';
import 'package:cermatify/app/routes/app_pages.dart';
import 'package:get/get.dart' as routes;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HttpService {
  final Dio _dio = Dio();
  static const String _tokenKey = 'token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static final HttpService _instance = HttpService._internal();

  factory HttpService() {
    return _instance;
  }

  HttpService._internal() {
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    _dio.options.baseUrl = ApiConstant.baseUrl;
    _dio.options.headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};

    // Add interceptor to include token in headers
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: _tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print('Added token to headers: $token');
          } else {
            print('No token found in storage');
          }
          return handler.next(options);
        },
        onError: (DioException e, ErrorInterceptorHandler handler) async {
          if (e.response?.statusCode == 401) {
            // On 401, clear token and navigate to login
            await _clearTokenAndNavigateToLogin();
            return handler.reject(e);
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> get(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(url, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> uploadFile(String url, File file) async {
    try {
      final formData = FormData.fromMap({
        'foto': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      });

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> postFormData(
    String url, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final formData = FormData.fromMap(data);

      final response = await _dio.post(
        url,
        data: formData,
        queryParameters: queryParameters,
        options: options?.copyWith(contentType: 'multipart/form-data') ?? Options(contentType: 'multipart/form-data'),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> putFormData(
    String url, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final formData = FormData.fromMap(data);

      final response = await _dio.put(
        url,
        data: formData,
        queryParameters: queryParameters,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {'Accept': 'application/json', ...?options?.headers},
        ),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final responseData = e.response!.data;
      final errorMessage = responseData is Map<String, dynamic> && responseData['message'] != null
          ? responseData['message'].toString()
          : 'An error occurred';

      switch (e.response!.statusCode) {
        case 400:
          return Exception('Bad Request: $errorMessage');
        case 401:
          return Exception('Unauthorized: $errorMessage');
        case 404:
          return Exception('Not Found: $errorMessage');
        case 500:
          return Exception('Internal Server Error: $errorMessage');
        default:
          return Exception('$errorMessage');
      }
    } else {
      return Exception('Network error: ${e.message}');
    }
  }

  Future<void> _clearTokenAndNavigateToLogin() async {
    try {
      await _storage.delete(key: _tokenKey);
      print('Token cleared, navigating to login');
      routes.Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      print('Error clearing token: $e');
    }
  }
}
