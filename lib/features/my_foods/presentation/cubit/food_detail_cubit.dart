import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/custom_food.dart';
import '../../domain/usecases/delete_custom_food_usecase.dart';
import '../../domain/usecases/toggle_favorite_food_usecase.dart';
import '../../domain/usecases/update_custom_food_usecase.dart';
import '../../../dashboard/domain/usecases/add_food_to_diet_usecase.dart';

part 'food_detail_state.dart';

class FoodDetailCubit extends Cubit<FoodDetailState> {
  FoodDetailCubit({
    required CustomFood food,
    required this.updateCustomFoodUsecase,
    required this.toggleFavoriteFoodUsecase,
    required this.deleteCustomFoodUsecase,
    required this.addFoodToDietUsecase,
  }) : super(FoodDetailState(food: food));

  final UpdateCustomFoodUsecase updateCustomFoodUsecase;
  final ToggleFavoriteFoodUsecase toggleFavoriteFoodUsecase;
  final DeleteCustomFoodUsecase deleteCustomFoodUsecase;
  final AddFoodToDietUsecase addFoodToDietUsecase;

  Future<void> toggleFavorite() async {
    final current = state.food;
    emit(state.copyWith(isProcessing: true, message: null));
    try {
      final updated = current.copyWith(isFavorite: !current.isFavorite);
      await toggleFavoriteFoodUsecase(current.id, updated.isFavorite);
      emit(state.copyWith(food: updated, isProcessing: false));
    } catch (e) {
      emit(state.copyWith(isProcessing: false, message: e.toString()));
    }
  }

  Future<void> updateFood({
    required String name,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) async {
    final updated = state.food.copyWith(
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );
    emit(state.copyWith(isProcessing: true, message: null));
    try {
      await updateCustomFoodUsecase(updated);
      emit(state.copyWith(food: updated, isProcessing: false));
    } catch (e) {
      emit(state.copyWith(isProcessing: false, message: e.toString()));
    }
  }

  Future<void> deleteFood() async {
    emit(state.copyWith(isProcessing: true, message: null));
    try {
      await deleteCustomFoodUsecase(state.food.id);
      emit(state.copyWith(isProcessing: false, deleted: true));
    } catch (e) {
      emit(state.copyWith(isProcessing: false, message: e.toString()));
    }
  }

  Future<void> addToDiet() async {
    emit(state.copyWith(isProcessing: true, message: null));
    try {
      final food = state.food;
      await addFoodToDietUsecase(
        name: food.name,
        calories: food.calories,
        protein: food.protein,
        carbs: food.carbs,
        fat: food.fat,
      );
      emit(state.copyWith(
        isProcessing: false,
        message: 'Added to diet',
      ));
    } catch (e) {
      emit(
        state.copyWith(
          isProcessing: false,
          message: e.toString(),
        ),
      );
    }
  }
}
