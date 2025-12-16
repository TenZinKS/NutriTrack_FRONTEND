import '../repositories/my_foods_repository.dart';

class ToggleFavoriteFoodUsecase {
  final MyFoodsRepository repository;

  ToggleFavoriteFoodUsecase(this.repository);

  Future<void> call(String id, bool isFavorite) {
    return repository.toggleFavorite(id, isFavorite);
  }
}
