import 'package:equatable/equatable.dart';

class MealPlanRequest extends Equatable {
  final String mealType;
  final String requirements;
  final int? calories;
  final int? protein;
  final int? carbs;
  final int? fat;

  const MealPlanRequest({
    required this.mealType,
    required this.requirements,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });

  MealPlanRequest copyWith({
    String? mealType,
    String? requirements,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
  }) {
    return MealPlanRequest(
      mealType: mealType ?? this.mealType,
      requirements: requirements ?? this.requirements,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }

  @override
  List<Object?> get props => [
        mealType,
        requirements,
        calories,
        protein,
        carbs,
        fat,
      ];
}
