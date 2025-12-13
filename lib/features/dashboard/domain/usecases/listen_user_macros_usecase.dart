import '../entities/user_macros.dart';
import '../repositories/macros_repository.dart';

class ListenUserMacrosUsecase {
  final MacrosRepository repository;

  ListenUserMacrosUsecase(this.repository);

  Stream<UserMacros> call() {
    return repository.listenToMacros();
  }
}
