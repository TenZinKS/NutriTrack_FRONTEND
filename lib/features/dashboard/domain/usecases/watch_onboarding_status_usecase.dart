import '../repositories/macros_repository.dart';

class WatchOnboardingStatusUsecase {
  final MacrosRepository repository;

  WatchOnboardingStatusUsecase(this.repository);

  Stream<bool> call() {
    return repository.watchOnboardingStatus();
  }
}
