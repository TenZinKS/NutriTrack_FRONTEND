import '../../domain/entities/meal_plan.dart';

class MealPlanModel extends MealPlan {
  const MealPlanModel({
    required super.title,
    required super.mealType,
    required super.requirements,
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.fat,
    required super.suggestion,
  });

  factory MealPlanModel.fromMap(Map<String, dynamic> map) {
    return MealPlanModel(
      title: map['title'] as String? ?? (map['name'] as String? ?? 'Meal'),
      mealType: map['mealType'] as String? ?? 'Meal',
      requirements: map['requirements'] as String? ?? '',
      calories: ((map['calories'] ?? 0) as num).toInt(),
      protein: ((map['protein'] ?? 0) as num).toInt(),
      carbs: ((map['carbs'] ?? 0) as num).toInt(),
      fat: ((map['fat'] ?? 0) as num).toInt(),
      suggestion: map['suggestion'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'mealType': mealType,
      'requirements': requirements,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'suggestion': suggestion,
    };
  }

  MealPlanModel copyWith({
    String? title,
    String? mealType,
    String? requirements,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    String? suggestion,
  }) {
    return MealPlanModel(
      title: title ?? this.title,
      mealType: mealType ?? this.mealType,
      requirements: requirements ?? this.requirements,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      suggestion: suggestion ?? this.suggestion,
    );
  }
}
