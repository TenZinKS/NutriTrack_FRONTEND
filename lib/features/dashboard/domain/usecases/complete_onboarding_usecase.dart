import '../repositories/macros_repository.dart';

class CompleteOnboardingUsecase {
  final MacrosRepository repository;

  CompleteOnboardingUsecase(this.repository);

  Future<void> call() {
    return repository.markOnboardingCompleted();
  }
}
