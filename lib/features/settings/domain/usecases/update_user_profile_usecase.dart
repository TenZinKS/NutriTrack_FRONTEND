import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

class UpdateUserProfileUsecase {
  final UserProfileRepository repository;

  UpdateUserProfileUsecase(this.repository);

  Future<void> call(UserProfile profile) {
    return repository.updateProfile(profile);
  }
}
