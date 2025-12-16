import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/domain/usecases/delete_account_usecase.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required this.getCurrentUserUsecase,
    required this.logoutUsecase,
    required this.deleteAccountUsecase,
  }) : super(const SettingsState());

  final GetCurrentUserUsecase getCurrentUserUsecase;
  final LogoutUsecase logoutUsecase;
  final DeleteAccountUsecase deleteAccountUsecase;

  Future<void> loadUser() async {
    emit(state.copyWith(status: SettingsStatus.loading, message: null));
    try {
      final user = await getCurrentUserUsecase() ?? AuthUser.empty;
      emit(state.copyWith(status: SettingsStatus.ready, user: user));
    } catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(loggingOut: true, message: null, lastAction: SettingsAction.none));
    try {
      await logoutUsecase();
      emit(
        state.copyWith(
          loggingOut: false,
          lastAction: SettingsAction.logout,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loggingOut: false,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> deleteAccount() async {
    emit(
      state.copyWith(
        deletingAccount: true,
        message: null,
        lastAction: SettingsAction.none,
      ),
    );
    try {
      await deleteAccountUsecase();
      emit(
        state.copyWith(
          deletingAccount: false,
          lastAction: SettingsAction.deleteAccount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          deletingAccount: false,
          message: e.toString(),
        ),
      );
    }
  }

  void resetAction() {
    emit(state.copyWith(lastAction: SettingsAction.none));
  }
}
