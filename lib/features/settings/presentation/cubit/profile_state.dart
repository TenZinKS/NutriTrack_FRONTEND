part of 'profile_cubit.dart';

enum ProfileStatus { initial, loading, ready, submitting, success, failure }

class ProfileState {
  final ProfileStatus status;
  final UserProfile? profile;
  final String? message;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.message,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    String? message,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      message: message,
    );
  }
}
