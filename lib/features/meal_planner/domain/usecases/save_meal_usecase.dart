import '../entities/meal_plan.dart';
import '../repositories/meal_planner_repository.dart';

class SaveMealUsecase {
  final MealPlannerRepository repository;

  SaveMealUsecase(this.repository);

  Future<void> call(MealPlan meal) {
    return repository.saveMeal(meal);
  }
}
