import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile> fetchProfile();
  Future<void> updateProfile(UserProfile profile);
}
