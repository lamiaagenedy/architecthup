import 'package:dio/dio.dart';

import '../../../../../core/exceptions/app_exception.dart';
import '../../../../../core/exceptions/network_exception.dart';
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
    try {
      final response = await _dioClient.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: <String, dynamic>{'email': email, 'password': password},
      );

      return _mapSession(response, rememberMe);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<void> logout() async {
    return;
  }

  @override
  Future<AuthSession> refreshToken({
    required String refreshToken,
    required bool rememberMe,
  }) async {
    throw NetworkException('Token refresh is not supported');
  }

  AuthSession _mapSession(
    Response<Map<String, dynamic>> response,
    bool rememberMe,
  ) {
    final body = response.data ?? <String, dynamic>{};
    final data = body['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body;

    final now = DateTime.now();
    final userJson = Map<String, dynamic>.from(
      data['user'] as Map? ??
          <String, dynamic>{
            'id': 'unknown',
            'email': '',
            'name': '',
            'createdAt': now.toIso8601String(),
          },
    );

    final role = userJson['role'] as String? ?? 'user';
    final tokenExpiry = role == 'manager'
        ? now.add(const Duration(hours: 8))
        : now.add(const Duration(days: 30));

    return AuthSession(
      accessToken: data['token'] as String? ?? '',
      refreshToken: data['refreshToken'] as String? ?? '',
      accessTokenExpiresAt: tokenExpiry,
      refreshTokenExpiresAt: tokenExpiry,
      rememberMe: rememberMe,
      user: User.fromJson(userJson),
    );
  }

  AppException _mapError(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      return NetworkException(
        data['message'] as String? ?? 'Network request failed',
      );
    }

    return NetworkException(error.message ?? 'Network request failed');
  }
}
