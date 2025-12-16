import 'package:equatable/equatable.dart';

import '../../domain/entities/meal_plan.dart';

enum MealPlannerStatus { initial, loading, success, failure, saving, saved }

class MealPlannerState extends Equatable {
  final MealPlannerStatus status;
  final MealPlan meal;
  final String? message;

  const MealPlannerState({
    this.status = MealPlannerStatus.initial,
    this.meal = MealPlan.empty,
    this.message,
  });

  MealPlannerState copyWith({
    MealPlannerStatus? status,
    MealPlan? meal,
    String? message,
  }) {
    return MealPlannerState(
      status: status ?? this.status,
      meal: meal ?? this.meal,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, meal, message];
}
