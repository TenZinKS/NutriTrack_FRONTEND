import '../repositories/auth_repository.dart';

class DeleteAccountUsecase {
  final AuthRepository repository;

  DeleteAccountUsecase(this.repository);

  Future<void> call() {
    return repository.deleteAccount();
  }
}
