import '../entities/user_macros.dart';
import '../repositories/macros_repository.dart';

class GetCurrentUserMacrosUsecase {
  final MacrosRepository repository;

  GetCurrentUserMacrosUsecase(this.repository);

  Future<UserMacros> call() {
    return repository.fetchCurrentMacros();
  }
}
