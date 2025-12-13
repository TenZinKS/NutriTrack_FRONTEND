import '../entities/user_macros.dart';
import '../repositories/macros_repository.dart';

class UpdateUserMacrosUsecase {
  final MacrosRepository repository;

  UpdateUserMacrosUsecase(this.repository);

  Future<void> call(UserMacros macros) {
    return repository.updateMacros(macros);
  }
}
