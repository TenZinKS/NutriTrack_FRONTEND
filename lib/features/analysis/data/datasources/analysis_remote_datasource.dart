import 'dart:math' as math;

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

  static const int _dailyPoints = 7;
  static const int _weeklyBuckets = 6;
  static const int _monthlyBuckets = 6;

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

    final fetchLimit = _limitForRange(range);

    final statsSnap = await firestore
        .collection('users')
        .doc(uid)
        .collection('daily_stats')
        .orderBy('date', descending: true)
        .limit(fetchLimit)
        .get();

    final entries = statsSnap.docs
        .map(_mapDailyStat)
        .whereType<_DailyStat>()
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (entries.isEmpty) {
      return AnalysisRangeModel.empty();
    }

    final normalizedRange = range.toLowerCase();
    if (normalizedRange == 'weekly') {
      return _buildWeeklyRange(entries);
    }
    if (normalizedRange == 'monthly') {
      return _buildMonthlyRange(entries);
    }
    return _buildDailyRange(entries);
  }

  int _limitForRange(String range) {
    return switch (range.toLowerCase()) {
      'weekly' => _weeklyBuckets * 7 * 2,
      'monthly' => _monthlyBuckets * 31,
      _ => _dailyPoints * 2,
    };
  }

  AnalysisRangeModel _buildDailyRange(List<_DailyStat> entries) {
    final startIndex = math.max(entries.length - _dailyPoints, 0);
    final selected = entries.sublist(startIndex);
    if (selected.isEmpty) {
      return AnalysisRangeModel.empty();
    }

    return _buildModel(
      actual: selected.map((e) => e.calories).toList(growable: false),
      goal: selected.map((e) => e.goalCalories).toList(growable: false),
      labels: selected.map((e) => _formatDayLabel(e.date)).toList(growable: false),
      entries: selected,
    );
  }

  AnalysisRangeModel _buildWeeklyRange(List<_DailyStat> entries) {
    final buckets = _groupByWeek(entries);
    if (buckets.isEmpty) {
      return AnalysisRangeModel.empty();
    }

    final recent = buckets.length <= _weeklyBuckets
        ? buckets
        : buckets.sublist(buckets.length - _weeklyBuckets);
    final usedEntries =
        recent.expand((bucket) => bucket.entries).toList(growable: false);

    return _buildModel(
      actual: recent
          .map((bucket) => _averageFor(bucket.entries, (stat) => stat.calories))
          .toList(growable: false),
      goal: recent
          .map(
            (bucket) => _averageFor(bucket.entries, (stat) => stat.goalCalories),
          )
          .toList(growable: false),
      labels:
          recent.map((bucket) => bucket.label).toList(growable: false),
      entries: usedEntries,
    );
  }

  AnalysisRangeModel _buildMonthlyRange(List<_DailyStat> entries) {
    final buckets = _groupByMonth(entries);
    if (buckets.isEmpty) {
      return AnalysisRangeModel.empty();
    }

    final recent = buckets.length <= _monthlyBuckets
        ? buckets
        : buckets.sublist(buckets.length - _monthlyBuckets);
    final usedEntries =
        recent.expand((bucket) => bucket.entries).toList(growable: false);

    return _buildModel(
      actual: recent
          .map((bucket) => _averageFor(bucket.entries, (stat) => stat.calories))
          .toList(growable: false),
      goal: recent
          .map(
            (bucket) => _averageFor(bucket.entries, (stat) => stat.goalCalories),
          )
          .toList(growable: false),
      labels:
          recent.map((bucket) => bucket.label).toList(growable: false),
      entries: usedEntries,
    );
  }

  double _averageFor(
    List<_DailyStat> entries,
    double Function(_DailyStat stat) selector,
  ) {
    if (entries.isEmpty) {
      return 0;
    }
    final total =
        entries.fold<double>(0, (prev, stat) => prev + selector(stat));
    return total / entries.length;
  }

  AnalysisRangeModel _buildModel({
    required List<double> actual,
    required List<double> goal,
    required List<String> labels,
    required List<_DailyStat> entries,
  }) {
    if (actual.isEmpty || goal.isEmpty || labels.isEmpty) {
      return AnalysisRangeModel.empty();
    }

    final protein =
        entries.fold<double>(0, (prev, stat) => prev + stat.protein);
    final carbs =
        entries.fold<double>(0, (prev, stat) => prev + stat.carbs);
    final fats =
        entries.fold<double>(0, (prev, stat) => prev + stat.fat);
    final macroTotal = (protein + carbs + fats).clamp(1, double.infinity);

    return AnalysisRangeModel(
      underGoalTrend: actual,
      overGoalTrend: goal,
      fatsPercentage: (fats / macroTotal) * 100,
      carbsPercentage: (carbs / macroTotal) * 100,
      proteinPercentage: (protein / macroTotal) * 100,
      labels: labels,
    );
  }

  List<_RangeBucket> _groupByWeek(List<_DailyStat> entries) {
    if (entries.isEmpty) {
      return const [];
    }

    final buckets = <_RangeBucket>[];
    var currentStart = _weekStart(entries.first.date);
    var currentEntries = <_DailyStat>[];

    for (final stat in entries) {
      final bucketStart = _weekStart(stat.date);
      if (currentEntries.isNotEmpty &&
          !_isSameDay(bucketStart, currentStart)) {
        buckets.add(
          _RangeBucket(
            entries: currentEntries,
            label: _weekLabel(
              currentEntries.first.date,
              currentEntries.last.date,
            ),
          ),
        );
        currentEntries = <_DailyStat>[];
        currentStart = bucketStart;
      }
      currentEntries.add(stat);
    }

    if (currentEntries.isNotEmpty) {
      buckets.add(
        _RangeBucket(
          entries: currentEntries,
          label: _weekLabel(
            currentEntries.first.date,
            currentEntries.last.date,
          ),
        ),
      );
    }

    return buckets;
  }

  List<_RangeBucket> _groupByMonth(List<_DailyStat> entries) {
    if (entries.isEmpty) {
      return const [];
    }

    final buckets = <_RangeBucket>[];
    var currentMonth = DateTime(entries.first.date.year, entries.first.date.month);
    var currentEntries = <_DailyStat>[];

    for (final stat in entries) {
      final statMonth = DateTime(stat.date.year, stat.date.month);
      if (currentEntries.isNotEmpty && !_isSameMonth(statMonth, currentMonth)) {
        buckets.add(
          _RangeBucket(
            entries: currentEntries,
            label: _monthLabel(currentMonth),
          ),
        );
        currentEntries = <_DailyStat>[];
        currentMonth = statMonth;
      }
      currentEntries.add(stat);
    }

    if (currentEntries.isNotEmpty) {
      buckets.add(
        _RangeBucket(
          entries: currentEntries,
          label: _monthLabel(currentMonth),
        ),
      );
    }

    return buckets;
  }

  _DailyStat? _mapDailyStat(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final ts = data['date'] as Timestamp?;
    final date = ts?.toDate() ?? _parseDateFromId(doc.id);
    if (date == null) {
      return null;
    }

    double _asDouble(dynamic value, [double fallback = 0]) {
      if (value is num) {
        return value.toDouble();
      }
      return fallback;
    }

    return _DailyStat(
      date: date,
      calories: _asDouble(data['calories']),
      goalCalories: _asDouble(data['goalCalories'], 2000),
      protein: _asDouble(data['protein']),
      carbs: _asDouble(data['carbs']),
      fat: _asDouble(data['fat']),
    );
  }

  DateTime _weekStart(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final daysToSubtract = normalized.weekday - DateTime.monday;
    return normalized.subtract(Duration(days: daysToSubtract));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  String _formatDayLabel(DateTime date) {
    const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final name = weekdayNames[(date.weekday - 1) % weekdayNames.length];
    return '$name ${date.day}';
  }

  String _weekLabel(DateTime start, DateTime end) {
    final startLabel = '${_monthShort(start.month)} ${start.day}';
    final endLabel = '${_monthShort(end.month)} ${end.day}';
    return '$startLabel - $endLabel';
  }

  String _monthLabel(DateTime month) {
    final base = _monthShort(month.month);
    return '$base ${month.year}';
  }

  DateTime? _parseDateFromId(String id) {
    final parts = id.split('-');
    if (parts.length != 3) {
      return null;
    }
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return null;
    }
    return DateTime(year, month, day);
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

class _DailyStat {
  final DateTime date;
  final double calories;
  final double goalCalories;
  final double protein;
  final double carbs;
  final double fat;

  const _DailyStat({
    required this.date,
    required this.calories,
    required this.goalCalories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class _RangeBucket {
  final List<_DailyStat> entries;
  final String label;

  const _RangeBucket({
    required this.entries,
    required this.label,
  });
}
