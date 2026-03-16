import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

abstract final class AppLogger {
  static const String _tag = '[ArchitectHub]';
  static bool _enableInfoLogs = kDebugMode;

  static void initialize(AppConfig config) {
    _enableInfoLogs = !config.isProduction && config.enableVerboseLogs;
    info('Logger initialized for ${config.environmentLabel}');
  }

  static void info(String message) {
    if (_enableInfoLogs) {
      debugPrint('$_tag $message');
    }
  }

  static void warning(String message) {
    debugPrint('$_tag warning: $message');
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    debugPrint('$_tag $message');
    if (error != null) {
      debugPrint('$_tag error: $error');
    }
    if (stackTrace != null) {
      debugPrint('$_tag stackTrace: $stackTrace');
    }
  }
}
