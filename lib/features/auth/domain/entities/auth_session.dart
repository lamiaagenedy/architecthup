import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'auth_session.freezed.dart';
part 'auth_session.g.dart';

@freezed
class AuthSession with _$AuthSession {
  const factory AuthSession({
    required String accessToken,
    required String refreshToken,
    required User user,
    required DateTime accessTokenExpiresAt,
    required DateTime refreshTokenExpiresAt,
    @Default(false) bool rememberMe,
  }) = _AuthSession;

  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionFromJson(json);
}
