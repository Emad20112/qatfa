import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_endpoints.dart';
import 'network_exceptions.dart';

/// عميل الشبكة المعتمد المبني على Dio
/// يدعم CancelToken لإلغاء الطلبات المتداخلة في البحث الفوري وتوفير باقة النت
class DioClient {
  late final Dio _dio;

  DioClient({String? baseUrl, List<Interceptor>? interceptors}) {
    final defaultUrl = (defaultTargetPlatform == TargetPlatform.android && !kIsWeb)
        ? ApiEndpoints.baseUrl
        : ApiEndpoints.desktopBaseUrl;

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? defaultUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip, deflate, br',
        },
      ),
    );

    if (interceptors != null) {
      _dio.interceptors.addAll(interceptors);
    }

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          logPrint: (obj) => debugPrint('[DioClient] $obj'),
        ),
      );
    }
  }

  Dio get dioInstance => _dio;

  /// تنفيذ طلب GET مع دعم إلغاء الطلب (CancelToken)
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// تنفيذ طلب POST
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// إنشاء CancelToken جديد للطلبات التفاعلية
  CancelToken createCancelToken() => CancelToken();
}
