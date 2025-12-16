import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/custom_food.dart';
import '../../domain/usecases/delete_custom_food_usecase.dart';
import '../../domain/usecases/listen_custom_foods_usecase.dart';
import '../../domain/usecases/toggle_favorite_food_usecase.dart';

enum MyFoodsStatus { initial, loading, success, failure }
enum MyFoodsFilter { all, favorites }

class MyFoodsState extends Equatable {
  final MyFoodsStatus status;
  final List<CustomFood> foods;
  final MyFoodsFilter filter;
  final String? message;

  const MyFoodsState({
    this.status = MyFoodsStatus.initial,
    this.foods = const [],
    this.filter = MyFoodsFilter.all,
    this.message,
  });

  MyFoodsState copyWith({
    MyFoodsStatus? status,
    List<CustomFood>? foods,
    MyFoodsFilter? filter,
    String? message,
  }) {
    return MyFoodsState(
      status: status ?? this.status,
      foods: foods ?? this.foods,
      filter: filter ?? this.filter,
      message: message,
    );
  }

  List<CustomFood> get visibleFoods {
    if (filter == MyFoodsFilter.favorites) {
      return foods.where((food) => food.isFavorite).toList();
    }
    return foods;
  }

  @override
  List<Object?> get props => [status, foods, filter, message];
}

class MyFoodsCubit extends Cubit<MyFoodsState> {
  final ListenCustomFoodsUsecase listenCustomFoodsUsecase;
  final ToggleFavoriteFoodUsecase toggleFavoriteFoodUsecase;
  final DeleteCustomFoodUsecase deleteCustomFoodUsecase;
  StreamSubscription<List<CustomFood>>? _subscription;

  MyFoodsCubit({
    required this.listenCustomFoodsUsecase,
    required this.toggleFavoriteFoodUsecase,
    required this.deleteCustomFoodUsecase,
  }) : super(const MyFoodsState());

  void loadFoods() {
    emit(state.copyWith(status: MyFoodsStatus.loading));
    _subscription?.cancel();
    _subscription = listenCustomFoodsUsecase().listen(
      (foods) {
        emit(
          state.copyWith(
            status: MyFoodsStatus.success,
            foods: foods,
            message: null,
          ),
        );
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: MyFoodsStatus.failure,
            message: error.toString(),
          ),
        );
      },
    );
  }

  void changeFilter(MyFoodsFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  Future<void> toggleFavorite(CustomFood food) async {
    await toggleFavoriteFoodUsecase(food.id, !food.isFavorite);
  }

  Future<void> deleteFood(String id) async {
    await deleteCustomFoodUsecase(id);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
