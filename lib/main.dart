import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/architect_hub_app.dart';
import 'app/bootstrap/app_bootstrap.dart';
import 'app/di/app_providers.dart';
import 'core/error/app_error_handler.dart';
import 'core/logger/app_logger.dart';

Future<void> main() async {
  AppErrorHandler.registerHandlers();

  await AppErrorHandler.guard(() async {
    WidgetsFlutterBinding.ensureInitialized();

    final bootstrap = await AppBootstrap.initialize();
    AppLogger.initialize(bootstrap.config);

    runApp(
      ProviderScope(
        overrides: [appBootstrapProvider.overrideWithValue(bootstrap)],
        child: const ArchitectHubApp(),
      ),
    );
  });
}
