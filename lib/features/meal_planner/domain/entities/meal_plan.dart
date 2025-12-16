import 'package:equatable/equatable.dart';

class MealPlan extends Equatable {
  final String mealType;
  final String requirements;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String suggestion;

  const MealPlan({
    required this.mealType,
    required this.requirements,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.suggestion,
  });

  static const empty = MealPlan(
    mealType: 'Breakfast',
    requirements: '',
    calories: 0,
    protein: 0,
    carbs: 0,
    fat: 0,
    suggestion: '',
  );

  MealPlan copyWith({
    String? mealType,
    String? requirements,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    String? suggestion,
  }) {
    return MealPlan(
      mealType: mealType ?? this.mealType,
      requirements: requirements ?? this.requirements,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      suggestion: suggestion ?? this.suggestion,
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
        suggestion,
      ];
}
