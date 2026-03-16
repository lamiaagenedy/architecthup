import '../../../domain/entities/auth_session.dart';

abstract interface class AuthRemoteDatasource {
  Future<AuthSession> login({
    required String email,
    required String password,
    required bool rememberMe,
  });

  Future<AuthSession> refreshToken({
    required String refreshToken,
    required bool rememberMe,
  });

  Future<void> logout();
}
