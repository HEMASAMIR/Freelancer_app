import 'package:dio/dio.dart';
import 'package:freelancer/core/costant/constant.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://${AppConstants.supabaseUrl}.supabase.co',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'apikey': AppConstants.supabaseAnonKey,
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        compact: true,
      ),
    ]);
  }

  // ── GET ──
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  // ── POST ──
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  // ── PUT ──
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  // ── PATCH ──
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  // ── DELETE ──
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }
}

// ── Auth Interceptor ──
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final message =
        err.response?.data?['msg'] ??
        err.response?.data?['message'] ??
        'حدث خطأ';

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: 'لا يوجد اتصال بالإنترنت',
            type: err.type,
          ),
        );
      case DioExceptionType.badResponse:
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            error: _mapStatusCode(statusCode, message.toString()),
            type: err.type,
          ),
        );
      default:
        return handler.reject(err);
    }
  }

  String _mapStatusCode(int? code, String fallback) {
    switch (code) {
      case 400:
        return 'طلب غير صحيح';
      case 401:
        return 'غير مصرح — سجل دخولك مرة أخرى';
      case 422:
        return 'بيانات غير صالحة';
      case 429:
        return 'طلبات كثيرة — حاول لاحقاً';
      case 500:
        return 'خطأ في السيرفر';
      default:
        return fallback;
    }
  }
}
