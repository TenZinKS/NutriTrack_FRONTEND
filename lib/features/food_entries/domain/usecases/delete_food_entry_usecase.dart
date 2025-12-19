import 'package:nutri_track/features/analysis/domain/repositories/analysis_repository.dart';
import 'package:nutri_track/features/dashboard/domain/repositories/macros_repository.dart';

import '../entities/food_entry.dart';
import '../repositories/food_entries_repository.dart';

class DeleteFoodEntryUsecase {
  DeleteFoodEntryUsecase({
    required this.repository,
    required this.macrosRepository,
    required this.analysisRepository,
  });

  final FoodEntriesRepository repository;
  final MacrosRepository macrosRepository;
  final AnalysisRepository analysisRepository;

  Future<void> call(FoodEntry entry) async {
    final current = await macrosRepository.fetchCurrentMacros();
    final updatedMacros = current.copyWith(
      caloriesConsumed: _clampMacro(current.caloriesConsumed - entry.calories),
      proteinConsumed: _clampMacro(current.proteinConsumed - entry.protein),
      carbsConsumed: _clampMacro(current.carbsConsumed - entry.carbs),
      fatConsumed: _clampMacro(current.fatConsumed - entry.fat),
    );

    await macrosRepository.updateMacros(updatedMacros);
    await repository.deleteEntry(entry.id);
    await analysisRepository.syncWithMacros(
      updatedMacros,
      deltaCalories: -entry.calories,
      deltaProtein: -entry.protein,
      deltaCarbs: -entry.carbs,
      deltaFat: -entry.fat,
    );
  }

  int _clampMacro(int value) {
    if (value < 0) return 0;
    if (value > 100000) return 100000;
    return value;
  }
}
