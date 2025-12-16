import '../entities/custom_food.dart';
import '../repositories/my_foods_repository.dart';

class SaveCustomFoodUsecase {
  final MyFoodsRepository repository;

  SaveCustomFoodUsecase(this.repository);

  Future<void> call(CustomFood food) {
    return repository.saveCustomFood(food);
  }
}
