import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_remote_datasource.dart';
import '../models/user_profile_model.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl({required this.remoteDatasource});

  final UserProfileRemoteDatasource remoteDatasource;

  @override
  Future<UserProfile> fetchProfile() async {
    return remoteDatasource.fetchProfile();
  }

  @override
  Future<void> updateProfile(UserProfile profile) {
    return remoteDatasource.updateProfile(
      UserProfileModel(
        name: profile.name,
        email: profile.email,
        gender: profile.gender,
        heightCm: profile.heightCm,
        weightKg: profile.weightKg,
      ),
    );
  }
}
