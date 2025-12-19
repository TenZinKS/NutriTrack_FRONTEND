import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/food_entry.dart';

class FoodEntryModel extends FoodEntry {
  const FoodEntryModel({
    required super.id,
    required super.name,
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.fat,
    required super.createdAt,
  });

  factory FoodEntryModel.fromDoc(String id, Map<String, dynamic> data) {
    final timestamp = data['createdAt'];
    DateTime created = DateTime.now();
    if (timestamp is Timestamp) {
      created = timestamp.toDate();
    } else if (timestamp is DateTime) {
      created = timestamp;
    } else if (timestamp is int) {
      created = DateTime.fromMillisecondsSinceEpoch(timestamp);
    }

    return FoodEntryModel(
      id: id,
      name: data['name'] as String? ?? 'Food',
      calories: (data['calories'] as num?)?.toInt() ?? 0,
      protein: (data['protein'] as num?)?.toInt() ?? 0,
      carbs: (data['carbs'] as num?)?.toInt() ?? 0,
      fat: (data['fat'] as num?)?.toInt() ?? 0,
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
