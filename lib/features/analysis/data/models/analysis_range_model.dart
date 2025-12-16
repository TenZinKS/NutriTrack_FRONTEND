import '../../domain/entities/analysis_range.dart';

class AnalysisRangeModel extends AnalysisRange {
  const AnalysisRangeModel({
    required super.underGoalTrend,
    required super.overGoalTrend,
    required super.fatsPercentage,
    required super.carbsPercentage,
    required super.proteinPercentage,
    required super.labels,
  });

  factory AnalysisRangeModel.fromMap(Map<String, dynamic> map) {
    final under = _doubleList(map['underGoalTrend']);
    final over = _doubleList(map['overGoalTrend']);
    final macro = map['macroDistribution'] as Map<String, dynamic>? ?? {};
    final labels = _stringList(map['labels']);

    return AnalysisRangeModel(
      underGoalTrend: under.isEmpty ? AnalysisRange.zeroTrend : under,
      overGoalTrend: over.isEmpty ? AnalysisRange.zeroTrend : over,
      fatsPercentage: (macro['fats'] ?? 0).toDouble(),
      carbsPercentage: (macro['carbs'] ?? 0).toDouble(),
      proteinPercentage: (macro['protein'] ?? 0).toDouble(),
      labels: labels.isEmpty ? AnalysisRange.defaultLabels : labels,
    );
  }

  factory AnalysisRangeModel.empty() {
    return const AnalysisRangeModel(
      underGoalTrend: AnalysisRange.zeroTrend,
      overGoalTrend: AnalysisRange.zeroTrend,
      fatsPercentage: 0,
      carbsPercentage: 0,
      proteinPercentage: 0,
      labels: AnalysisRange.defaultLabels,
    );
  }

  static List<double> _doubleList(dynamic value) {
    if (value is Iterable) {
      return value
          .map<double>((e) => (e ?? 0).toDouble())
          .toList(growable: false);
    }
    return const <double>[];
  }

  static List<String> _stringList(dynamic value) {
    if (value is Iterable) {
      return value
          .map((e) => e?.toString() ?? '')
          .where((element) => element.isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
  }
}
