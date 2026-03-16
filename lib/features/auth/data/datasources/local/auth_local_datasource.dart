import 'package:hive/hive.dart';

import '../../../domain/entities/auth_session.dart';

class AuthLocalDatasource {
  AuthLocalDatasource(this._box);

  final Box<dynamic> _box;

  static const String sessionKey = 'auth_session';

  Future<void> saveSession(AuthSession session) async {
    await _box.put(sessionKey, <String, dynamic>{
      'accessToken': session.accessToken,
      'refreshToken': session.refreshToken,
      'user': session.user.toJson(),
      'accessTokenExpiresAt': session.accessTokenExpiresAt.toIso8601String(),
      'refreshTokenExpiresAt': session.refreshTokenExpiresAt.toIso8601String(),
      'rememberMe': session.rememberMe,
    });
  }

  AuthSession? readSession() {
    final rawValue = _box.get(sessionKey);
    if (rawValue is! Map) {
      return null;
    }

    return AuthSession.fromJson(Map<String, dynamic>.from(rawValue));
  }

  String? readAccessToken() => readSession()?.accessToken;

  String? readRefreshToken() => readSession()?.refreshToken;

  Future<void> clearSession() async {
    await _box.delete(sessionKey);
  }
}
