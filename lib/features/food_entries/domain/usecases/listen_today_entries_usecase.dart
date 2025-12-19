import '../entities/food_entry.dart';
import '../repositories/food_entries_repository.dart';

class ListenTodayEntriesUsecase {
  ListenTodayEntriesUsecase(this.repository);

  final FoodEntriesRepository repository;

  Stream<List<FoodEntry>> call() {
    return repository.listenTodayEntries();
  }
}
