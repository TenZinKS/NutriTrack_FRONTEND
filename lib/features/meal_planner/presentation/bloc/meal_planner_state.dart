import 'package:equatable/equatable.dart';

import '../../domain/entities/meal_plan.dart';
import '../../domain/entities/meal_plan_request.dart';

enum MealPlannerStatus { initial, loading, success, failure, saving, saved }

class MealPlannerState extends Equatable {
  final MealPlannerStatus status;
  final List<MealPlan> meals;
  final int selectedIndex;
  final MealPlanRequest? lastRequest;
  final String? message;

  const MealPlannerState({
    this.status = MealPlannerStatus.initial,
    this.meals = const [],
    this.selectedIndex = 0,
    this.lastRequest,
    this.message,
  });

  MealPlan? get selectedMeal {
    if (meals.isEmpty) return null;
    var index = selectedIndex;
    if (index < 0) index = 0;
    if (index >= meals.length) index = meals.length - 1;
    return meals[index];
  }

  bool get hasMeals => meals.isNotEmpty;

  MealPlannerState copyWith({
    MealPlannerStatus? status,
    List<MealPlan>? meals,
    int? selectedIndex,
    MealPlanRequest? lastRequest,
    String? message,
  }) {
    return MealPlannerState(
      status: status ?? this.status,
      meals: meals ?? this.meals,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      lastRequest: lastRequest ?? this.lastRequest,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, meals, selectedIndex, lastRequest, message];
}
