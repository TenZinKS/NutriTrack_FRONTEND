import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_track/features/food_entries/domain/entities/food_entry.dart';
import 'package:nutri_track/features/food_entries/domain/usecases/delete_food_entry_usecase.dart';
import 'package:nutri_track/features/food_entries/domain/usecases/listen_today_entries_usecase.dart';
import 'package:nutri_track/features/food_entries/domain/usecases/update_food_entry_usecase.dart';
import '../../../dashboard/domain/usecases/add_food_to_diet_usecase.dart';

part 'today_entries_state.dart';

class TodayEntriesCubit extends Cubit<TodayEntriesState> {
  TodayEntriesCubit({
    required this.listenTodayEntriesUsecase,
    required this.updateFoodEntryUsecase,
    required this.deleteFoodEntryUsecase,
    required this.addFoodToDietUsecase,
  }) : super(const TodayEntriesState());

  final ListenTodayEntriesUsecase listenTodayEntriesUsecase;
  final UpdateFoodEntryUsecase updateFoodEntryUsecase;
  final DeleteFoodEntryUsecase deleteFoodEntryUsecase;
  final AddFoodToDietUsecase addFoodToDietUsecase;
  StreamSubscription<List<FoodEntry>>? _subscription;

  void loadEntries() {
    emit(state.copyWith(status: TodayEntriesStatus.loading, message: null));
    _subscription?.cancel();
    _subscription = listenTodayEntriesUsecase().listen(
      (entries) {
        emit(
          state.copyWith(
            status: TodayEntriesStatus.success,
            entries: entries,
          ),
        );
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: TodayEntriesStatus.failure,
            message: error.toString(),
          ),
        );
      },
    );
  }

  Future<void> updateEntry(
    FoodEntry entry, {
    required String name,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) async {
    emit(state.copyWith(actionInProgress: true, message: null));
    try {
      await updateFoodEntryUsecase(
        original: entry,
        name: name,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );
      emit(state.copyWith(actionInProgress: false));
    } catch (e) {
      emit(
        state.copyWith(
          actionInProgress: false,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> deleteEntry(FoodEntry entry) async {
    emit(state.copyWith(actionInProgress: true, message: null));
    try {
      await deleteFoodEntryUsecase(entry);
      emit(state.copyWith(actionInProgress: false));
    } catch (e) {
      emit(
        state.copyWith(
          actionInProgress: false,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> addEntryToDiet(FoodEntry entry) async {
    emit(state.copyWith(actionInProgress: true, message: null));
    try {
      await addFoodToDietUsecase(
        name: entry.name,
        calories: entry.calories,
        protein: entry.protein,
        carbs: entry.carbs,
        fat: entry.fat,
      );
      emit(
        state.copyWith(
          actionInProgress: false,
          message: 'Entry added to diet',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionInProgress: false,
          message: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
