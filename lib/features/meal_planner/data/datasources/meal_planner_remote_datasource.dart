import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/app_config.dart';
import '../../domain/entities/meal_plan_request.dart';
import '../models/meal_plan_model.dart';

abstract class MealPlannerRemoteDatasource {
  Future<List<MealPlanModel>> generateMeals(MealPlanRequest request);
  Future<void> saveMeal(MealPlanModel meal);
}

class MealPlannerRemoteDatasourceImpl implements MealPlannerRemoteDatasource {
  MealPlannerRemoteDatasourceImpl({
    required this.firestore,
    required this.firebaseAuth,
    required this.httpClient,
  });

  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final http.Client httpClient;

  @override
  Future<List<MealPlanModel>> generateMeals(MealPlanRequest request) async {
    final apiKey = AppConfig.openRouterApiKey;
    if (apiKey.isEmpty) {
      throw Exception(
        'Missing OpenRouter API key. Provide it via --dart-define=OPENROUTER_API_KEY=YOUR_KEY.',
      );
    }

    final uri = Uri.parse(AppConfig.openRouterBaseUrl);
    final payload = _buildRequestPayload(request);

    try {
      final response = await httpClient
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
              if (AppConfig.openRouterReferer.isNotEmpty)
                'HTTP-Referer': AppConfig.openRouterReferer,
              'X-Title': AppConfig.openRouterTitle,
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode >= 400) {
        final errorDetails =
            response.body.isNotEmpty ? ' Details: ${response.body}' : '';
        if (response.statusCode == 401) {
          throw Exception(
            'OpenRouter rejected the API key. Ensure OPENROUTER_API_KEY is set via --dart-define or your env config.$errorDetails',
          );
        }
        throw Exception(
          'Unable to generate meals (code ${response.statusCode}). Please try again.$errorDetails',
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final contentNode = decoded['choices']?[0]?['message']?['content'];
      final content = _normalizeContent(contentNode);
      if (content.isEmpty) {
        throw Exception('OpenRouter returned an empty response.');
      }

      final parsedBody = _extractJson(content);
      final mealsPayload = parsedBody['meals'];
      if (mealsPayload is! List || mealsPayload.isEmpty) {
        throw Exception('DeepSeek could not find meals for that request.');
      }

      return mealsPayload
          .whereType<Map<String, dynamic>>()
          .map((meal) => _mapMeal(meal, request))
          .toList(growable: false);
    } on TimeoutException {
      throw Exception('OpenRouter request timed out. Please try again.');
    }
  }

  @override
  Future<void> saveMeal(MealPlanModel meal) async {
    final uid = firebaseAuth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not authenticated');
    }

    final foodsRef = firestore
        .collection('users')
        .doc(uid)
        .collection('customFoods');

    await foodsRef.add({
      'name': meal.title.isNotEmpty ? meal.title : meal.mealType,
      'calories': meal.calories,
      'protein': meal.protein,
      'carbs': meal.carbs,
      'fat': meal.fat,
      'createdAt': FieldValue.serverTimestamp(),
      'isFavorite': false,
      'source': 'ai_meal_planner',
      'notes': meal.suggestion,
      'mealType': meal.mealType,
    });
  }

  Map<String, dynamic> _buildRequestPayload(MealPlanRequest request) {
    final macros = <String>[
      if (request.calories != null) '${request.calories} kcal',
      if (request.protein != null) '${request.protein}g protein',
      if (request.carbs != null) '${request.carbs}g carbs',
      if (request.fat != null) '${request.fat}g fat',
    ].join(', ');

    final userPrompt = StringBuffer()
      ..writeln('Meal type: ${request.mealType}')
      ..writeln('Dietary requirements: ${request.requirements.isEmpty ? 'None specified' : request.requirements}')
      ..writeln(macros.isEmpty
          ? 'Try to keep the meal well balanced.'
          : 'Macronutrient targets: $macros.')
      ..writeln('Return 3 concise meal options. Each option needs:')
      ..writeln('- title')
      ..writeln('- short description')
      ..writeln('- calories, protein, carbs, fat integers');

    return {
      'model': AppConfig.openRouterModel,
      'temperature': 0.6,
      'messages': [
        {
          'role': 'system',
          'content':
              'You are an expert sports nutrition coach. Always respond with strict JSON matching { "meals": [ { "title": "...", "description": "...", "calories": 0, "protein": 0, "carbs": 0, "fat": 0 } ] }. DO NOT wrap the JSON in code fences.',
        },
        {
          'role': 'user',
          'content': userPrompt.toString(),
        },
      ],
    };
  }

  String _normalizeContent(dynamic contentNode) {
    if (contentNode is String) {
      return contentNode.trim();
    }
    if (contentNode is List) {
      return contentNode
          .map((item) {
            if (item is Map<String, dynamic>) {
              return (item['text'] ?? item['content'] ?? '').toString();
            }
            return item.toString();
          })
          .where((piece) => piece.trim().isNotEmpty)
          .join('\n')
          .trim();
    }
    return '';
  }

  Map<String, dynamic> _extractJson(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      final start = body.indexOf('{');
      final end = body.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        final candidate = body.substring(start, end + 1);
        return jsonDecode(candidate) as Map<String, dynamic>;
      }
      throw Exception('Unable to parse OpenRouter response. Please try again.');
    }
  }

  MealPlanModel _mapMeal(
    Map<String, dynamic> data,
    MealPlanRequest request,
  ) {
    int _asInt(dynamic value, int fallback) {
      if (value is num) {
        return value.round();
      }
      return fallback;
    }

    return MealPlanModel(
      title: (data['title'] ?? data['name'] ?? request.mealType).toString(),
      mealType: request.mealType,
      requirements: request.requirements,
      calories: _asInt(data['calories'], request.calories ?? 0),
      protein: _asInt(data['protein'], request.protein ?? 0),
      carbs: _asInt(data['carbs'], request.carbs ?? 0),
      fat: _asInt(data['fat'], request.fat ?? 0),
      suggestion: (data['description'] ?? data['instructions'] ?? '')
          .toString()
          .trim(),
    );
  }
}
