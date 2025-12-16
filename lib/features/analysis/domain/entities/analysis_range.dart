import 'package:equatable/equatable.dart';

class AnalysisRange extends Equatable {
  static const List<double> zeroTrend = [0, 0, 0, 0, 0, 0, 0];
  static const List<String> defaultLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  final List<double> underGoalTrend;
  final List<double> overGoalTrend;
  final double fatsPercentage;
  final double carbsPercentage;
  final double proteinPercentage;
  final List<String> labels;

  const AnalysisRange({
    required this.underGoalTrend,
    required this.overGoalTrend,
    required this.fatsPercentage,
    required this.carbsPercentage,
    required this.proteinPercentage,
    required this.labels,
  });

  static const empty = AnalysisRange(
    underGoalTrend: zeroTrend,
    overGoalTrend: zeroTrend,
    fatsPercentage: 0,
    carbsPercentage: 0,
    proteinPercentage: 0,
    labels: defaultLabels,
  );

  AnalysisRange copyWith({
    List<double>? underGoalTrend,
    List<double>? overGoalTrend,
    double? fatsPercentage,
    double? carbsPercentage,
    double? proteinPercentage,
    List<String>? labels,
  }) {
    return AnalysisRange(
      underGoalTrend: underGoalTrend ?? this.underGoalTrend,
      overGoalTrend: overGoalTrend ?? this.overGoalTrend,
      fatsPercentage: fatsPercentage ?? this.fatsPercentage,
      carbsPercentage: carbsPercentage ?? this.carbsPercentage,
      proteinPercentage: proteinPercentage ?? this.proteinPercentage,
      labels: labels ?? this.labels,
    );
  }

  @override
  List<Object?> get props => [
        underGoalTrend,
        overGoalTrend,
        fatsPercentage,
        carbsPercentage,
        proteinPercentage,
        labels,
      ];
}
