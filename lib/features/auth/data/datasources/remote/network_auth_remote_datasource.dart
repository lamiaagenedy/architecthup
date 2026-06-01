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
      final response = await _dioClient.dio.post<dynamic>(
        '/auth/login',
        data: <String, dynamic>{'email': email, 'password': password},
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      return _mapSession(body, rememberMe);
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

  AuthSession _mapSession(Map<String, dynamic> body, bool rememberMe) {
    final rawData = body['data'];
    final data = rawData is Map ? Map<String, dynamic>.from(rawData) : body;

    final now = DateTime.now();
    final rawUser = data['user'];
    final userJson = rawUser is Map
        ? Map<String, dynamic>.from(rawUser)
        : <String, dynamic>{
            'id': 'unknown',
            'email': '',
            'name': '',
            'createdAt': now.toIso8601String(),
          };

    final role = _normalizeRole(userJson['role'] as String?);
    userJson['role'] = role;
    final tokenExpiry = role == 'Manager'
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
    if (data is Map) {
      final mapped = Map<String, dynamic>.from(data);
      return NetworkException(
        mapped['message'] as String? ?? 'Network request failed',
      );
    }
    return NetworkException(error.message ?? 'Network request failed');
  }

  String _normalizeRole(String? rawRole) {
    final normalized = rawRole?.trim().toLowerCase();
    if (normalized == 'manager') {
      return 'Manager';
    }
    return 'Engineer';
  }
}
