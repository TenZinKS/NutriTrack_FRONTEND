import '../entities/custom_food.dart';
import '../repositories/my_foods_repository.dart';

class ListenCustomFoodsUsecase {
  final MyFoodsRepository repository;

  ListenCustomFoodsUsecase(this.repository);

  Stream<List<CustomFood>> call() {
    return repository.listenCustomFoods();
  }
}
