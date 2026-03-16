import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/logger/app_logger.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_auth_session_usecase.dart';
import '../../domain/usecases/load_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(
      getAuthSession: ref.watch(getAuthSessionUsecaseProvider),
      loadCurrentUser: ref.watch(loadCurrentUserUsecaseProvider),
      loginUsecase: ref.watch(loginUsecaseProvider),
      logoutUsecase: ref.watch(logoutUsecaseProvider),
    );
  },
);

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required GetAuthSessionUsecase getAuthSession,
    required LoadCurrentUserUsecase loadCurrentUser,
    required LoginUsecase loginUsecase,
    required LogoutUsecase logoutUsecase,
  }) : _getAuthSession = getAuthSession,
       _loadCurrentUser = loadCurrentUser,
       _loginUsecase = loginUsecase,
       _logoutUsecase = logoutUsecase,
       super(const AuthState.initial());

  final GetAuthSessionUsecase _getAuthSession;
  final LoadCurrentUserUsecase _loadCurrentUser;
  final LoginUsecase _loginUsecase;
  final LogoutUsecase _logoutUsecase;
  Future<void>? _initializeFuture;
  bool _hasInitialized = false;

  Future<void> initialize() async {
    if (_hasInitialized) {
      return;
    }
    if (_initializeFuture != null) {
      return _initializeFuture;
    }

    _initializeFuture = _runInitialize();
    await _initializeFuture;
  }

  Future<void> _runInitialize() async {
    state = state.copyWith(status: AuthStatus.checking, clearError: true);

    try {
      final session = await _getAuthSession();
      if (session == null) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          session: null,
          clearError: true,
        );
        _hasInitialized = true;
        return;
      }

      final user = await _loadCurrentUser() ?? session.user;
      state = state.copyWith(
        status: AuthStatus.authenticated,
        session: session.copyWith(user: user),
        clearError: true,
      );
      _hasInitialized = true;
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to initialize auth state',
        error: error,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        session: null,
        clearError: true,
      );
      _hasInitialized = true;
    } finally {
      _initializeFuture = null;
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final session = await _loginUsecase(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        session: session,
        isSubmitting: false,
        clearError: true,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isSubmitting: false,
        errorMessage: error.message,
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Unexpected login failure',
        error: error,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isSubmitting: false,
        errorMessage: 'Something went wrong while signing in.',
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      await _logoutUsecase();
    } catch (error, stackTrace) {
      AppLogger.error('Logout failed', error: error, stackTrace: stackTrace);
    }

    state = const AuthState.unauthenticated();
  }

  void clearError() {
    if (state.errorMessage == null) {
      return;
    }

    state = state.copyWith(clearError: true);
  }
}

@immutable
class AuthState {
  const AuthState({
    required this.status,
    required this.isSubmitting,
    required this.session,
    required this.errorMessage,
  });

  const AuthState.initial()
    : this(
        status: AuthStatus.idle,
        isSubmitting: false,
        session: null,
        errorMessage: null,
      );

  const AuthState.unauthenticated()
    : this(
        status: AuthStatus.unauthenticated,
        isSubmitting: false,
        session: null,
        errorMessage: null,
      );

  final AuthStatus status;
  final bool isSubmitting;
  final AuthSession? session;
  final String? errorMessage;

  bool get isChecking => status == AuthStatus.checking;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    bool? isSubmitting,
    AuthSession? session,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      session: session ?? this.session,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

enum AuthStatus { idle, checking, unauthenticated, authenticated }

final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(authControllerProvider).session?.user,
);

final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authControllerProvider).isAuthenticated,
);
