import '../../domain/entities/analysis_range.dart';

enum AnalysisStatus { initial, loading, success, failure }

class AnalysisState {
  final AnalysisStatus status;
  final AnalysisRange data;
  final String range;
  final String? message;

  const AnalysisState({
    this.status = AnalysisStatus.initial,
    this.data = AnalysisRange.empty,
    this.range = 'daily',
    this.message,
  });

  AnalysisState copyWith({
    AnalysisStatus? status,
    AnalysisRange? data,
    String? range,
    String? message,
  }) {
    return AnalysisState(
      status: status ?? this.status,
      data: data ?? this.data,
      range: range ?? this.range,
      message: message,
    );
  }
}
