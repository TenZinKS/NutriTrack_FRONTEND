import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUsecase {
  final AuthRepository repository;

  GetCurrentUserUsecase(this.repository);

  Future<AuthUser?> call() {
    return repository.currentUser();
  }
}
