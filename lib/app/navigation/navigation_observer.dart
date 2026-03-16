import 'package:flutter/widgets.dart';

import '../../core/logger/app_logger.dart';

class AppNavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.info('Navigation push: ${_describeRoute(route)}');
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.info('Navigation pop: ${_describeRoute(route)}');
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      AppLogger.info('Navigation replace: ${_describeRoute(newRoute)}');
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  String _describeRoute(Route<dynamic> route) {
    return route.settings.name ?? route.runtimeType.toString();
  }
}
