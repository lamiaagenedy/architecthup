import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  const LoginUsecase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({
    required String email,
    required String password,
    required bool rememberMe,
  }) {
    return _repository.login(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
  }
}
