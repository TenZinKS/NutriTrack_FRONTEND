import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutri_track/features/dashboard/domain/entities/user_macros.dart';

import '../models/analysis_range_model.dart';

abstract class AnalysisRemoteDatasource {
  Future<AnalysisRangeModel> fetchRange(String range);
  Future<void> syncWithMacros(
    UserMacros macros, {
    required int deltaCalories,
    required int deltaProtein,
    required int deltaCarbs,
    required int deltaFat,
  });
}

class AnalysisRemoteDatasourceImpl implements AnalysisRemoteDatasource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  AnalysisRemoteDatasourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<AnalysisRangeModel> fetchRange(String range) async {
    final uid = firebaseAuth.currentUser?.uid;
    if (uid == null) {
      return AnalysisRangeModel.empty();
    }

    final days = switch (range.toLowerCase()) {
      'weekly' => 14,
      'monthly' => 30,
      _ => 7,
    };

    final statsSnap = await firestore
        .collection('users')
        .doc(uid)
        .collection('daily_stats')
        .orderBy('date', descending: true)
        .limit(days)
        .get();

    if (statsSnap.docs.isEmpty) {
      return AnalysisRangeModel.empty();
    }

    final docs = statsSnap.docs.reversed.toList();
    final actual = docs
        .map((doc) => ((doc.data()['calories'] ?? 0) as num).toDouble())
        .toList();
    final targets = docs
        .map((doc) => ((doc.data()['goalCalories'] ?? 2000) as num).toDouble())
        .toList();
    final labels = docs.map((doc) {
      final ts = doc.data()['date'] as Timestamp?;
      final date = ts?.toDate();
      if (date == null) {
        return '';
      }
      return '${_monthShort(date.month)} ${date.day}';
    }).toList();

    final protein = docs
        .map((doc) => ((doc.data()['protein'] ?? 0) as num).toDouble())
        .fold<double>(0, (prev, value) => prev + value);
    final carbs = docs
        .map((doc) => ((doc.data()['carbs'] ?? 0) as num).toDouble())
        .fold<double>(0, (prev, value) => prev + value);
    final fats = docs
        .map((doc) => ((doc.data()['fat'] ?? 0) as num).toDouble())
        .fold<double>(0, (prev, value) => prev + value);

    final macroTotal = (protein + carbs + fats).clamp(1, double.infinity);

    return AnalysisRangeModel(
      underGoalTrend: actual,
      overGoalTrend: targets,
      fatsPercentage: (fats / macroTotal) * 100,
      carbsPercentage: (carbs / macroTotal) * 100,
      proteinPercentage: (protein / macroTotal) * 100,
      labels: labels,
    );
  }

  @override
  Future<void> syncWithMacros(
    UserMacros macros, {
    required int deltaCalories,
    required int deltaProtein,
    required int deltaCarbs,
    required int deltaFat,
  }) async {
    final uid = (macros.uid.isNotEmpty
            ? macros.uid
            : firebaseAuth.currentUser?.uid) ??
        '';
    if (uid.isEmpty) return;

    final todayKey = _todayKey();
    final statsRef = firestore
        .collection('users')
        .doc(uid)
        .collection('daily_stats')
        .doc(todayKey);

    await statsRef.set(
      {
        'date': Timestamp.fromDate(DateTime.now()),
        'goalCalories': macros.caloriesGoal,
        'goalProtein': macros.proteinGoal,
        'goalCarbs': macros.carbsGoal,
        'goalFat': macros.fatGoal,
        'calories': FieldValue.increment(deltaCalories),
        'protein': FieldValue.increment(deltaProtein),
        'carbs': FieldValue.increment(deltaCarbs),
        'fat': FieldValue.increment(deltaFat),
      },
      SetOptions(merge: true),
    );
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _monthShort(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month < 1 || month > names.length) return 'Jan';
    return names[month - 1];
  }
}
