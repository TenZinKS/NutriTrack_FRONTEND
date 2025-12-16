import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../dashboard/domain/entities/user_macros.dart';
import '../../../dashboard/domain/usecases/complete_onboarding_usecase.dart';
import '../../../dashboard/domain/usecases/get_current_user_macros_usecase.dart';
import '../../../dashboard/domain/usecases/update_user_macros_usecase.dart';
import '../../domain/entities/nutrition_targets.dart';
import '../../domain/usecases/calculate_nutrition_targets_usecase.dart';

part 'welcome_goals_state.dart';

class WelcomeGoalsCubit extends Cubit<WelcomeGoalsState> {
  WelcomeGoalsCubit({
    required this.getCurrentUserMacrosUsecase,
    required this.updateUserMacrosUsecase,
    required this.completeOnboardingUsecase,
    required this.calculateNutritionTargetsUsecase,
  }) : super(const WelcomeGoalsState());

  final GetCurrentUserMacrosUsecase getCurrentUserMacrosUsecase;
  final UpdateUserMacrosUsecase updateUserMacrosUsecase;
  final CompleteOnboardingUsecase completeOnboardingUsecase;
  final CalculateNutritionTargetsUsecase calculateNutritionTargetsUsecase;

  Future<void> loadGoals() async {
    _emitState(
      state.copyWith(status: WelcomeGoalsStatus.loading, message: null),
    );
    try {
      final macros = await getCurrentUserMacrosUsecase();
      final hasExisting = macros.uid.isNotEmpty;
      final normalized = hasExisting
          ? macros
          : macros.copyWith(
              caloriesGoal: 0,
              carbsGoal: 0,
              proteinGoal: 0,
              fatGoal: 0,
              waterGoal: 0,
            );
      _emitState(
        state.copyWith(
          status: WelcomeGoalsStatus.ready,
          baseMacros: macros,
          caloriesGoal: normalized.caloriesGoal,
          carbsGoal: normalized.carbsGoal,
          proteinGoal: normalized.proteinGoal,
          fatGoal: normalized.fatGoal,
          waterGoal: normalized.waterGoal,
        ),
      );
    } catch (e) {
      _emitState(
        state.copyWith(
          status: WelcomeGoalsStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  NutritionTargets applyCalculatedTargets({
    required NutritionGender gender,
    required double heightCm,
    required double currentWeightKg,
    required double targetWeightKg,
    required NutritionActivityLevel activityLevel,
  }) {
    final targets = calculateNutritionTargetsUsecase(
      gender: gender,
      heightCm: heightCm,
      currentWeightKg: currentWeightKg,
      targetWeightKg: targetWeightKg,
      activityLevel: activityLevel,
    );

    _emitState(
      state.copyWith(
        caloriesGoal: targets.calories,
        carbsGoal: targets.carbsGrams,
        proteinGoal: targets.proteinGrams,
        fatGoal: targets.fatGrams,
      ),
    );

    return targets;
  }

  void _emitState(WelcomeGoalsState newState) {
    if (isClosed) return;
    emit(newState);
  }

  Future<void> saveGoals() async {
    _emitState(
      state.copyWith(status: WelcomeGoalsStatus.submitting, message: null),
    );
    try {
      final base = state.baseMacros ?? UserMacros.empty();
      final macros = base.copyWith(
        caloriesGoal: state.caloriesGoal,
        carbsGoal: state.carbsGoal,
        proteinGoal: state.proteinGoal,
        fatGoal: state.fatGoal,
        waterGoal: state.waterGoal,
      );

      await updateUserMacrosUsecase(macros);
      await completeOnboardingUsecase();

      _emitState(state.copyWith(status: WelcomeGoalsStatus.success));
    } catch (e) {
      _emitState(
        state.copyWith(
          status: WelcomeGoalsStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }
}
