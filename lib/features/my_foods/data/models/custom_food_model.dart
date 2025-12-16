import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/custom_food.dart';

class CustomFoodModel extends CustomFood {
  const CustomFoodModel({
    required super.id,
    required super.name,
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.fat,
    super.isFavorite,
  });

  factory CustomFoodModel.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return CustomFoodModel(
      id: doc.id,
      name: (data['name'] ?? '') as String,
      calories: ((data['calories'] ?? 0) as num).toInt(),
      protein: ((data['protein'] ?? 0) as num).toInt(),
      carbs: ((data['carbs'] ?? 0) as num).toInt(),
      fat: ((data['fat'] ?? 0) as num).toInt(),
      isFavorite: (data['isFavorite'] ?? false) as bool,
    );
  }
}
