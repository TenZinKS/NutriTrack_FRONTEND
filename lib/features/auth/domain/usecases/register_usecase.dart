import '../repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  Future<void> call(String name, String email, String password) {
    return repository.register(name, email, password);
  }
}
