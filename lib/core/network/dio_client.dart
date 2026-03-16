import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../logger/app_logger.dart';

class DioClient {
  DioClient({required AppConfig config})
    : dio = Dio(
        BaseOptions(
          baseUrl: config.apiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          contentType: Headers.jsonContentType,
        ),
      ) {
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
