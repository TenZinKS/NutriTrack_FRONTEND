import '../../domain/entities/custom_food.dart';
import '../../domain/repositories/my_foods_repository.dart';
import '../datasources/my_foods_remote_datasource.dart';

class MyFoodsRepositoryImpl implements MyFoodsRepository {
  MyFoodsRepositoryImpl({required this.remoteDatasource});

  final MyFoodsRemoteDatasource remoteDatasource;

  @override
  Future<void> saveCustomFood(CustomFood food) {
    return remoteDatasource.saveCustomFood({
      'name': food.name,
      'calories': food.calories,
      'protein': food.protein,
      'carbs': food.carbs,
      'fat': food.fat,
      'isFavorite': food.isFavorite,
    });
  }

  @override
  Stream<List<CustomFood>> listenCustomFoods() {
    return remoteDatasource.listenCustomFoods();
  }

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) {
    return remoteDatasource.toggleFavorite(id, isFavorite);
  }

  @override
  Future<void> deleteCustomFood(String id) {
    return remoteDatasource.deleteCustomFood(id);
  }
}
