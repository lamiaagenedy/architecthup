import '../../../../../core/network/dio_client.dart';
import '../../../domain/entities/auth_session.dart';
import '../../../domain/entities/user.dart';
import 'auth_remote_datasource.dart';

class NetworkAuthRemoteDatasource implements AuthRemoteDatasource {
  NetworkAuthRemoteDatasource(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: <String, dynamic>{'email': email, 'password': password},
    );

    return _mapSession(response.data ?? <String, dynamic>{}, rememberMe);
  }

  @override
  Future<void> logout() async {
    await _dioClient.dio.post<dynamic>('/auth/logout');
  }

  @override
  Future<AuthSession> refreshToken({
    required String refreshToken,
    required bool rememberMe,
  }) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: <String, dynamic>{'refreshToken': refreshToken},
    );

    return _mapSession(response.data ?? <String, dynamic>{}, rememberMe);
  }

  AuthSession _mapSession(Map<String, dynamic> json, bool rememberMe) {
    final now = DateTime.now();
    final userJson = Map<String, dynamic>.from(
      json['user'] as Map? ??
          <String, dynamic>{
            'id': 'unknown',
            'email': '',
            'name': '',
            'createdAt': now.toIso8601String(),
          },
    );

    return AuthSession(
      accessToken: json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      accessTokenExpiresAt: now.add(const Duration(minutes: 15)),
      refreshTokenExpiresAt: now.add(const Duration(days: 7)),
      rememberMe: rememberMe,
      user: User.fromJson(userJson),
    );
  }
}
