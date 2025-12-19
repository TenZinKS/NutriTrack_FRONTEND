import '../../domain/entities/meal_plan.dart';
import '../../domain/entities/meal_plan_request.dart';
import '../../domain/repositories/meal_planner_repository.dart';
import '../datasources/meal_planner_remote_datasource.dart';
import '../models/meal_plan_model.dart';

class MealPlannerRepositoryImpl implements MealPlannerRepository {
  MealPlannerRepositoryImpl({required this.remoteDatasource});

  final MealPlannerRemoteDatasource remoteDatasource;

  @override
  Future<List<MealPlan>> generateMeals(MealPlanRequest request) {
    return remoteDatasource.generateMeals(request);
  }

  @override
  Future<void> saveMeal(MealPlan meal) {
    return remoteDatasource.saveMeal(
      MealPlanModel(
        title: meal.title,
        mealType: meal.mealType,
        requirements: meal.requirements,
        calories: meal.calories,
        protein: meal.protein,
        carbs: meal.carbs,
        fat: meal.fat,
        suggestion: meal.suggestion,
      ),
    );
  }

}
