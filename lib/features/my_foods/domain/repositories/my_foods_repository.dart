import '../entities/custom_food.dart';

abstract class MyFoodsRepository {
  Future<void> saveCustomFood(CustomFood food);
  Stream<List<CustomFood>> listenCustomFoods();
  Future<void> toggleFavorite(String id, bool isFavorite);
  Future<void> deleteCustomFood(String id);
}
