import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this.getUserProfileUsecase,
    required this.updateUserProfileUsecase,
  }) : super(const ProfileState());

  final GetUserProfileUsecase getUserProfileUsecase;
  final UpdateUserProfileUsecase updateUserProfileUsecase;

  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading, message: null));
    try {
      final profile = await getUserProfileUsecase();
      emit(state.copyWith(status: ProfileStatus.ready, profile: profile));
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> save(UserProfile profile) async {
    emit(state.copyWith(status: ProfileStatus.submitting, message: null));
    try {
      await updateUserProfileUsecase(profile);
      emit(state.copyWith(status: ProfileStatus.success, profile: profile));
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }
}
