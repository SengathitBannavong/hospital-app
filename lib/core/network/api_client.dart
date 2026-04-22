import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: Duration(seconds: AppConfig.timeoutSeconds),
    ),
  )..interceptors.addAll([AuthInterceptor(), ErrorInterceptor()]);

  static Dio get instance => _dio;
}
