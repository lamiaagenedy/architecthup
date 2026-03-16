import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../logger/app_logger.dart';

abstract final class AppErrorHandler {
  static void registerHandlers() {
    final previousOnError = FlutterError.onError;

    FlutterError.onError = (details) {
      previousOnError?.call(details);
      AppLogger.error(
        'Flutter framework error',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      AppLogger.error(
        'Uncaught platform error',
        error: error,
        stackTrace: stackTrace,
      );
      return true;
    };
  }

  static Future<void> guard(Future<void> Function() action) {
    return runZonedGuarded(action, (error, stackTrace) {
          AppLogger.error(
            'Uncaught zoned error',
            error: error,
            stackTrace: stackTrace,
          );
        }) ??
        Future<void>.value();
  }
}
