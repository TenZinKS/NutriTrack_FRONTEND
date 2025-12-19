import '../../domain/entities/food_entry.dart';
import '../../domain/repositories/food_entries_repository.dart';
import '../datasources/food_entries_remote_datasource.dart';
import '../models/food_entry_model.dart';

class FoodEntriesRepositoryImpl implements FoodEntriesRepository {
  FoodEntriesRepositoryImpl({required this.remote});

  final FoodEntriesRemoteDatasource remote;

  @override
  Stream<List<FoodEntry>> listenTodayEntries() {
    return remote.listenTodayEntries();
  }

  @override
  Future<FoodEntry> addEntry(FoodEntry entry) async {
    final model = FoodEntryModel(
      id: entry.id,
      name: entry.name,
      calories: entry.calories,
      protein: entry.protein,
      carbs: entry.carbs,
      fat: entry.fat,
      createdAt: entry.createdAt,
    );
    return remote.addEntry(model);
  }

  @override
  Future<void> updateEntry(FoodEntry entry) {
    final model = FoodEntryModel(
      id: entry.id,
      name: entry.name,
      calories: entry.calories,
      protein: entry.protein,
      carbs: entry.carbs,
      fat: entry.fat,
      createdAt: entry.createdAt,
    );
    return remote.updateEntry(model);
  }

  @override
  Future<void> deleteEntry(String id) {
    return remote.deleteEntry(id);
  }
}
