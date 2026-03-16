import '../../../../../core/exceptions/app_exception.dart';
import '../../../domain/entities/auth_session.dart';
import '../../../domain/entities/user.dart';
import 'auth_remote_datasource.dart';

class MockAuthRemoteDatasource implements AuthRemoteDatasource {
  static const String demoEmail = 'user@example.com';
  static const String demoPassword = 'securePassword123';

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (email != demoEmail || password != demoPassword) {
      throw const AppException(
        'Invalid credentials. Use user@example.com / securePassword123 for the mock flow.',
      );
    }

    final now = DateTime.now();

    return AuthSession(
      accessToken: 'mock-access-token',
      refreshToken: 'mock-refresh-token',
      accessTokenExpiresAt: now.add(const Duration(minutes: 15)),
      refreshTokenExpiresAt: now.add(const Duration(days: 7)),
      rememberMe: rememberMe,
      user: User(
        id: 'user1',
        email: demoEmail,
        name: 'John Smith',
        role: 'manager',
        avatarUrl: 'https://example.com/avatar.png',
        createdAt: now,
      ),
    );
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<AuthSession> refreshToken({
    required String refreshToken,
    required bool rememberMe,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();

    return AuthSession(
      accessToken: 'mock-access-token-refreshed',
      refreshToken: refreshToken,
      accessTokenExpiresAt: now.add(const Duration(minutes: 15)),
      refreshTokenExpiresAt: now.add(const Duration(days: 7)),
      rememberMe: rememberMe,
      user: User(
        id: 'user1',
        email: demoEmail,
        name: 'John Smith',
        role: 'manager',
        avatarUrl: 'https://example.com/avatar.png',
        createdAt: now,
      ),
    );
  }
}
