import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/meal_plan_request.dart';
import '../../domain/usecases/generate_meal_plan_usecase.dart';
import '../../domain/usecases/save_meal_usecase.dart';
import 'meal_planner_event.dart';
import 'meal_planner_state.dart';

class MealPlannerBloc extends Bloc<MealPlannerEvent, MealPlannerState> {
  MealPlannerBloc({
    required this.generateMealPlanUsecase,
    required this.saveMealUsecase,
  }) : super(const MealPlannerState()) {
    on<GenerateMealPlanEvent>(_onGenerateMeal);
    on<SaveMealEvent>(_onSaveMeal);
  }

  final GenerateMealPlanUsecase generateMealPlanUsecase;
  final SaveMealUsecase saveMealUsecase;

  Future<void> _onGenerateMeal(
    GenerateMealPlanEvent event,
    Emitter<MealPlannerState> emit,
  ) async {
    emit(state.copyWith(status: MealPlannerStatus.loading, message: null));
    try {
      final meal = await generateMealPlanUsecase(event.request);
      emit(
        state.copyWith(
          status: MealPlannerStatus.success,
          meal: meal,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MealPlannerStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSaveMeal(
    SaveMealEvent event,
    Emitter<MealPlannerState> emit,
  ) async {
    emit(state.copyWith(status: MealPlannerStatus.saving, message: null));
    try {
      await saveMealUsecase(event.meal);
      emit(state.copyWith(status: MealPlannerStatus.saved));
    } catch (e) {
      emit(
        state.copyWith(
          status: MealPlannerStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }
}
