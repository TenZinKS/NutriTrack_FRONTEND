import 'package:nutri_track/features/analysis/domain/repositories/analysis_repository.dart';
import 'package:nutri_track/features/dashboard/domain/entities/user_macros.dart';
import 'package:nutri_track/features/dashboard/domain/repositories/macros_repository.dart';
import 'package:nutri_track/features/food_entries/domain/entities/food_entry.dart';
import 'package:nutri_track/features/food_entries/domain/repositories/food_entries_repository.dart';

class AddFoodToDietUsecase {
  final MacrosRepository macrosRepository;
  final AnalysisRepository analysisRepository;
  final FoodEntriesRepository foodEntriesRepository;

  AddFoodToDietUsecase(
    this.macrosRepository,
    this.analysisRepository,
    this.foodEntriesRepository,
  );

  Future<void> call({
    required String name,
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
    await foodEntriesRepository.addEntry(
      FoodEntry(
        id: '',
        name: name,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        createdAt: DateTime.now(),
      ),
    );
  }
}
