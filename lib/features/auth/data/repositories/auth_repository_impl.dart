import '../../../../core/exceptions/app_exception.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthLocalDatasource localDatasource,
    required AuthRemoteDatasource remoteDatasource,
  }) : _localDatasource = localDatasource,
       _remoteDatasource = remoteDatasource;

  final AuthLocalDatasource _localDatasource;
  final AuthRemoteDatasource _remoteDatasource;

  @override
  Future<void> clearSession() => _localDatasource.clearSession();

  @override
  Future<String?> getAccessToken() async => _localDatasource.readAccessToken();

  @override
  Future<User?> getCurrentUser() async => _localDatasource.readSession()?.user;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final session = await _remoteDatasource.login(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
    if (rememberMe) {
      await _localDatasource.saveSession(session);
    } else {
      await _localDatasource.clearSession();
    }
    return session;
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDatasource.logout();
    } on AppException {
      rethrow;
    } finally {
      await _localDatasource.clearSession();
    }
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final session = _localDatasource.readSession();
    if (session == null) {
      return null;
    }

    if (!session.rememberMe) {
      await _localDatasource.clearSession();
      return null;
    }

    if (session.refreshTokenExpiresAt.isBefore(DateTime.now())) {
      await _localDatasource.clearSession();
      return null;
    }

    return session;
  }
}
