import 'package:nutri_track/features/analysis/domain/repositories/analysis_repository.dart';
import 'package:nutri_track/features/dashboard/domain/entities/user_macros.dart';
import 'package:nutri_track/features/dashboard/domain/repositories/macros_repository.dart';

class AddFoodToDietUsecase {
  final MacrosRepository macrosRepository;
  final AnalysisRepository analysisRepository;

  AddFoodToDietUsecase(
    this.macrosRepository,
    this.analysisRepository,
  );

  Future<void> call({
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) async {
    final current = await macrosRepository.fetchCurrentMacros();
    final updated = current.copyWith(
      caloriesConsumed: current.caloriesConsumed + calories,
      proteinConsumed: current.proteinConsumed + protein,
      carbsConsumed: current.carbsConsumed + carbs,
      fatConsumed: current.fatConsumed + fat,
    );

    await macrosRepository.updateMacros(updated);
    await analysisRepository.syncWithMacros(
      updated,
      deltaCalories: calories,
      deltaProtein: protein,
      deltaCarbs: carbs,
      deltaFat: fat,
    );
  }
}
