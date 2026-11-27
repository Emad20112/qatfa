import 'package:dio/dio.dart';

/// استثناءات الشبكة والاتصال الموحدة
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const NetworkException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  factory NetworkException.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        return const NetworkException(
          message: 'تم إلغاء الطلب.',
          statusCode: -1,
        );
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'انتهت مهلة الاتصال بالخادم. تحقق من جودة الإنترنت.',
          statusCode: 408,
        );
      case DioExceptionType.badResponse:
        final status = dioError.response?.statusCode;
        final data = dioError.response?.data;
        String msg = 'حدث خطأ في الخادم ($status)';
        if (data is Map && data['message'] != null) {
          msg = data['message'].toString();
        }
        return NetworkException(
          message: msg,
          statusCode: status,
          originalError: data,
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'تعذر الاتصال بالخادم. أنت في وضع عدم الاتصال.',
          statusCode: 0,
        );
      default:
        return NetworkException(
          message: 'حدث خطأ غير متوقع في الشبكة.',
          originalError: dioError.message,
        );
    }
  }

  @override
  String toString() => 'NetworkException: $message (code: $statusCode)';
}
