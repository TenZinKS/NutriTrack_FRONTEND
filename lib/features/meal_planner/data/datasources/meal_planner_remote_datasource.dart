import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/meal_plan_request.dart';
import '../models/meal_plan_model.dart';

abstract class MealPlannerRemoteDatasource {
  Future<MealPlanModel> generateMeal(MealPlanRequest request);
  Future<void> saveMeal(MealPlanModel meal);
}

class MealPlannerRemoteDatasourceImpl implements MealPlannerRemoteDatasource {
  MealPlannerRemoteDatasourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  @override
  Future<MealPlanModel> generateMeal(MealPlanRequest request) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final random = Random();

    final calories = request.calories ?? (random.nextInt(400) + 300);
    final protein = request.protein ?? (random.nextInt(40) + 20);
    final carbs = request.carbs ?? (random.nextInt(50) + 30);
    final fat = request.fat ?? (random.nextInt(25) + 10);

    final suggestion = _buildSuggestion(request, protein, carbs, fat);

    return MealPlanModel(
      mealType: request.mealType,
      requirements: request.requirements,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      suggestion: suggestion,
    );
  }

  @override
  Future<void> saveMeal(MealPlanModel meal) async {
    final uid = firebaseAuth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not authenticated');
    }

    final doc = firestore
        .collection('users')
        .doc(uid)
        .collection('meals')
        .doc();

    await doc.set(meal.toMap()
      ..addAll({
        'createdAt': FieldValue.serverTimestamp(),
      }));
  }

  String _buildSuggestion(
    MealPlanRequest request,
    int protein,
    int carbs,
    int fat,
  ) {
    final base = request.requirements.isEmpty
        ? 'Balanced ${request.mealType.toLowerCase()} bowl'
        : request.requirements;

    return '$base with ~$protein g protein, $carbs g carbs, and $fat g fat.';
  }
}
