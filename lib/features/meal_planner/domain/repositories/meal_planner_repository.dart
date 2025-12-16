import '../entities/meal_plan.dart';
import '../entities/meal_plan_request.dart';

abstract class MealPlannerRepository {
  Future<MealPlan> generateMeal(MealPlanRequest request);
  Future<void> saveMeal(MealPlan meal);
}
