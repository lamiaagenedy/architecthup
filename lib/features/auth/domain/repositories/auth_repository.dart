import '../entities/auth_session.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  Future<AuthSession?> restoreSession();

  Future<AuthSession> login({
    required String email,
    required String password,
    required bool rememberMe,
  });

  Future<void> logout();

  Future<String?> getAccessToken();

  Future<User?> getCurrentUser();

  Future<void> clearSession();
}
