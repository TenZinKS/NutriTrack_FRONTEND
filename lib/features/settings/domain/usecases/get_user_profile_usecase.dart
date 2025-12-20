import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

class GetUserProfileUsecase {
  final UserProfileRepository repository;

  GetUserProfileUsecase(this.repository);

  Future<UserProfile> call() {
    return repository.fetchProfile();
  }
}
