import 'package:flutter/foundation.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/splash/presentation/providers/splash_flow_provider.dart';

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier({
    required AuthState authState,
    required SplashFlowState splashState,
  }) : _authState = authState,
       _splashState = splashState;

  AuthState _authState;
  SplashFlowState _splashState;

  AuthState get authState => _authState;
  SplashFlowState get splashState => _splashState;

  void updateAuthState(AuthState value) {
    _authState = value;
    refresh();
  }

  void updateSplashState(SplashFlowState value) {
    _splashState = value;
    refresh();
  }

  void refresh() {
    notifyListeners();
  }
}
