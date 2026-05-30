import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../logger/app_logger.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._readToken);

  final String? Function() _readToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class DioClient {
  DioClient({
    required AppConfig config,
    String? Function()? readAccessToken,
  }) : dio = Dio(
         BaseOptions(
           baseUrl: config.apiBaseUrl,
           connectTimeout: const Duration(seconds: 15),
           receiveTimeout: const Duration(seconds: 15),
           sendTimeout: const Duration(seconds: 15),
           contentType: Headers.jsonContentType,
         ),
       ) {
    if (readAccessToken != null) {
      dio.interceptors.add(AuthInterceptor(readAccessToken));
    }

    if (config.enableHttpLogs) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            AppLogger.info('HTTP ${options.method} ${options.uri}');
            handler.next(options);
          },
          onError: (error, handler) {
            AppLogger.error(
              'HTTP ${error.requestOptions.method} ${error.requestOptions.uri}',
              error: error,
              stackTrace: error.stackTrace,
            );
            handler.next(error);
          },
        ),
      );
    }
  }

  final Dio dio;
}
