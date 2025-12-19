import '../entities/custom_food.dart';
import '../repositories/my_foods_repository.dart';

class UpdateCustomFoodUsecase {
  UpdateCustomFoodUsecase(this.repository);

  final MyFoodsRepository repository;

  Future<void> call(CustomFood food) {
    return repository.updateCustomFood(food);
  }
}
