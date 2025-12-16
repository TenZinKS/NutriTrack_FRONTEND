import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../dashboard/domain/entities/user_macros.dart';
import '../../../dashboard/domain/usecases/get_current_user_macros_usecase.dart';
import '../../../dashboard/domain/usecases/update_user_macros_usecase.dart';

part 'update_macros_state.dart';

class UpdateMacrosCubit extends Cubit<UpdateMacrosState> {
  UpdateMacrosCubit({
    required this.getCurrentUserMacrosUsecase,
    required this.updateUserMacrosUsecase,
  }) : super(const UpdateMacrosState());

  final GetCurrentUserMacrosUsecase getCurrentUserMacrosUsecase;
  final UpdateUserMacrosUsecase updateUserMacrosUsecase;

  Future<void> loadMacros() async {
    emit(state.copyWith(status: UpdateMacrosStatus.loading, message: null));
    try {
      final macros = await getCurrentUserMacrosUsecase();
      emit(
        state.copyWith(
          status: UpdateMacrosStatus.ready,
          baseMacros: macros,
          caloriesGoal: macros.caloriesGoal,
          carbsGoal: macros.carbsGoal,
          proteinGoal: macros.proteinGoal,
          fatGoal: macros.fatGoal,
          waterGoal: macros.waterGoal,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: UpdateMacrosStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  void updateCalories(String value) {
    emit(state.copyWith(caloriesGoal: _parseGoal(value, state.caloriesGoal)));
  }

  void updateCarbs(String value) {
    emit(state.copyWith(carbsGoal: _parseGoal(value, state.carbsGoal)));
  }

  void updateProtein(String value) {
    emit(state.copyWith(proteinGoal: _parseGoal(value, state.proteinGoal)));
  }

  void updateFat(String value) {
    emit(state.copyWith(fatGoal: _parseGoal(value, state.fatGoal)));
  }

  void updateWater(String value) {
    emit(state.copyWith(waterGoal: _parseGoal(value, state.waterGoal)));
  }

  Future<void> save() async {
    emit(state.copyWith(status: UpdateMacrosStatus.submitting, message: null));
    try {
      final base = state.baseMacros ?? UserMacros.empty();
      final updated = base.copyWith(
        caloriesGoal: state.caloriesGoal,
        carbsGoal: state.carbsGoal,
        proteinGoal: state.proteinGoal,
        fatGoal: state.fatGoal,
        waterGoal: state.waterGoal,
      );
      await updateUserMacrosUsecase(updated);
      emit(state.copyWith(status: UpdateMacrosStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: UpdateMacrosStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  int _parseGoal(String value, int fallback) {
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 0) return fallback;
    return parsed;
  }
}
