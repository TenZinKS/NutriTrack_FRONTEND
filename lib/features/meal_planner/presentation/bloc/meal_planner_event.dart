import '../../domain/entities/meal_plan.dart';
import '../../domain/entities/meal_plan_request.dart';

abstract class MealPlannerEvent {}

class GenerateMealPlanEvent extends MealPlannerEvent {
  final MealPlanRequest request;
  GenerateMealPlanEvent(this.request);
}

class RegenerateMealPlanEvent extends MealPlannerEvent {}

class SelectMealOptionEvent extends MealPlannerEvent {
  final int index;
  SelectMealOptionEvent(this.index);
}

class SaveMealEvent extends MealPlannerEvent {
  final MealPlan meal;
  SaveMealEvent(this.meal);
}
