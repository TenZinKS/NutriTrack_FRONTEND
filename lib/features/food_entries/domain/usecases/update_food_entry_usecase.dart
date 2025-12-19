import 'package:nutri_track/features/analysis/domain/repositories/analysis_repository.dart';
import 'package:nutri_track/features/dashboard/domain/repositories/macros_repository.dart';

import '../entities/food_entry.dart';
import '../repositories/food_entries_repository.dart';

class UpdateFoodEntryUsecase {
  UpdateFoodEntryUsecase({
    required this.repository,
    required this.macrosRepository,
    required this.analysisRepository,
  });

  final FoodEntriesRepository repository;
  final MacrosRepository macrosRepository;
  final AnalysisRepository analysisRepository;

  Future<void> call({
    required FoodEntry original,
    required String name,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) async {
    final deltaCalories = calories - original.calories;
    final deltaProtein = protein - original.protein;
    final deltaCarbs = carbs - original.carbs;
    final deltaFat = fat - original.fat;

    final current = await macrosRepository.fetchCurrentMacros();
    final updatedMacros = current.copyWith(
      caloriesConsumed: _clampMacro(current.caloriesConsumed + deltaCalories),
      proteinConsumed: _clampMacro(current.proteinConsumed + deltaProtein),
      carbsConsumed: _clampMacro(current.carbsConsumed + deltaCarbs),
      fatConsumed: _clampMacro(current.fatConsumed + deltaFat),
    );

    final updatedEntry = original.copyWith(
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );

    await macrosRepository.updateMacros(updatedMacros);
    await repository.updateEntry(updatedEntry);
    await analysisRepository.syncWithMacros(
      updatedMacros,
      deltaCalories: deltaCalories,
      deltaProtein: deltaProtein,
      deltaCarbs: deltaCarbs,
      deltaFat: deltaFat,
    );
  }

  int _clampMacro(int value) {
    if (value < 0) return 0;
    if (value > 100000) return 100000;
    return value;
  }
}
