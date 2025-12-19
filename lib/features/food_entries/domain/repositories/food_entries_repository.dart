import '../entities/food_entry.dart';

abstract class FoodEntriesRepository {
  Stream<List<FoodEntry>> listenTodayEntries();
  Future<FoodEntry> addEntry(FoodEntry entry);
  Future<void> updateEntry(FoodEntry entry);
  Future<void> deleteEntry(String id);
}
