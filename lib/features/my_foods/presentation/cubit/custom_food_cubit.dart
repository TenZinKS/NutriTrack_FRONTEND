import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../dashboard/domain/usecases/add_food_to_diet_usecase.dart';
import '../../domain/entities/custom_food.dart';
import '../../domain/usecases/save_custom_food_usecase.dart';

enum CustomFoodAction { none, saveToFoods, addToDiet }

class CustomFoodState extends Equatable {
  final bool savingFoods;
  final bool savingDiet;
  final CustomFoodAction lastAction;
  final String? message;

  const CustomFoodState({
    this.savingFoods = false,
    this.savingDiet = false,
    this.lastAction = CustomFoodAction.none,
    this.message,
  });

  CustomFoodState copyWith({
    bool? savingFoods,
    bool? savingDiet,
    CustomFoodAction? lastAction,
    String? message,
  }) {
    return CustomFoodState(
      savingFoods: savingFoods ?? this.savingFoods,
      savingDiet: savingDiet ?? this.savingDiet,
      lastAction: lastAction ?? this.lastAction,
      message: message,
    );
  }

  @override
  List<Object?> get props => [savingFoods, savingDiet, lastAction, message];
}

class CustomFoodCubit extends Cubit<CustomFoodState> {
  final SaveCustomFoodUsecase saveCustomFoodUsecase;
  final AddFoodToDietUsecase addFoodToDietUsecase;

  CustomFoodCubit({
    required this.saveCustomFoodUsecase,
    required this.addFoodToDietUsecase,
  }) : super(const CustomFoodState());

  Future<void> saveToFoods(CustomFood food) async {
    emit(state.copyWith(
      savingFoods: true,
      lastAction: CustomFoodAction.none,
      message: null,
    ));
    try {
      await saveCustomFoodUsecase(food);
      emit(
        state.copyWith(
          savingFoods: false,
          lastAction: CustomFoodAction.saveToFoods,
        ),
      );
    } catch (e) {
      emit(state.copyWith(
        savingFoods: false,
        message: e.toString(),
      ));
    }
  }

  Future<void> addToDiet(CustomFood food) async {
    emit(state.copyWith(
      savingDiet: true,
      lastAction: CustomFoodAction.none,
      message: null,
    ));
    try {
      await addFoodToDietUsecase(
        name: food.name,
        calories: food.calories,
        protein: food.protein,
        carbs: food.carbs,
        fat: food.fat,
      );
      await saveCustomFoodUsecase(food);
      emit(
        state.copyWith(
          savingDiet: false,
          lastAction: CustomFoodAction.addToDiet,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          savingDiet: false,
          message: e.toString(),
        ),
      );
    }
  }
}
