import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_macros.dart';

class UserMacrosModel extends UserMacros {
  const UserMacrosModel({
    required super.uid,
    required super.name,
    required super.caloriesGoal,
    required super.caloriesConsumed,
    required super.carbsGoal,
    required super.carbsConsumed,
    required super.proteinGoal,
    required super.proteinConsumed,
    required super.fatGoal,
    required super.fatConsumed,
    required super.waterGoal,
    required super.waterConsumed,
  });

  factory UserMacrosModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    final macros = (data['macros'] as Map<String, dynamic>?) ?? {};

    int _value(String key, int fallback) {
      final raw = macros[key];
      if (raw is int) return raw;
      if (raw is double) return raw.toInt();
      if (raw is num) return raw.toInt();
      return fallback;
    }

    return UserMacrosModel(
      uid: (data['uid'] ?? snapshot.id) as String,
      name: (data['name'] ?? '') as String,
      caloriesGoal: _value('caloriesGoal', 2000),
      caloriesConsumed: _value('caloriesConsumed', 0),
      carbsGoal: _value('carbsGoal', 200),
      carbsConsumed: _value('carbsConsumed', 0),
      proteinGoal: _value('proteinGoal', 120),
      proteinConsumed: _value('proteinConsumed', 0),
      fatGoal: _value('fatGoal', 70),
      fatConsumed: _value('fatConsumed', 0),
      waterGoal: _value('waterGoal', 2000),
      waterConsumed: _value('waterConsumed', 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'caloriesGoal': caloriesGoal,
      'caloriesConsumed': caloriesConsumed,
      'carbsGoal': carbsGoal,
      'carbsConsumed': carbsConsumed,
      'proteinGoal': proteinGoal,
      'proteinConsumed': proteinConsumed,
      'fatGoal': fatGoal,
      'fatConsumed': fatConsumed,
      'waterGoal': waterGoal,
      'waterConsumed': waterConsumed,
    };
  }
}
