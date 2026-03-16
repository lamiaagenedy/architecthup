import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoadCurrentUserUsecase {
  const LoadCurrentUserUsecase(this._repository);

  final AuthRepository _repository;

  Future<User?> call() => _repository.getCurrentUser();
}
