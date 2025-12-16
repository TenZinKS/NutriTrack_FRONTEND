import '../entities/meal_plan.dart';
import '../entities/meal_plan_request.dart';
import '../repositories/meal_planner_repository.dart';

class GenerateMealPlanUsecase {
  final MealPlannerRepository repository;

  GenerateMealPlanUsecase(this.repository);

  Future<MealPlan> call(MealPlanRequest request) {
    return repository.generateMeal(request);
  }
}
