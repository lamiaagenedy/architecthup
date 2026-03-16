import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/config/app_config.dart';
import '../../core/logger/app_logger.dart';
import 'app_bootstrap_failure.dart';

/// Holds app-wide services created before the widget tree starts.
class AppBootstrap {
  AppBootstrap({
    required this.config,
    required this.preferencesBox,
    required this.authBox,
    required this.appDocumentsPath,
  });

  final AppConfig config;

  final Box<dynamic> preferencesBox;
  final Box<dynamic> authBox;
  final String appDocumentsPath;

  static const String preferencesBoxName = 'app_preferences';
  static const String authBoxName = 'auth_session';

  static Future<AppBootstrap> initialize() async {
    try {
      final config = AppConfig.fromEnvironment();
      await Hive.initFlutter();

      final documentsDirectory = await getApplicationDocumentsDirectory();
      final preferencesBox = await Hive.openBox<dynamic>(preferencesBoxName);
      final authBox = await Hive.openBox<dynamic>(authBoxName);

      AppLogger.info('Bootstrap initialized for ${config.environmentLabel}');

      return AppBootstrap(
        config: config,
        preferencesBox: preferencesBox,
        authBox: authBox,
        appDocumentsPath: documentsDirectory.path,
      );
    } catch (error) {
      throw AppBootstrapFailure(
        'Failed to initialize application services.',
        cause: error,
      );
    }
  }
}
