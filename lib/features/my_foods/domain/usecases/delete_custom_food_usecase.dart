import '../repositories/my_foods_repository.dart';

class DeleteCustomFoodUsecase {
  final MyFoodsRepository repository;

  DeleteCustomFoodUsecase(this.repository);

  Future<void> call(String id) {
    return repository.deleteCustomFood(id);
  }
}
