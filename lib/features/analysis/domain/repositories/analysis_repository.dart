import '../entities/analysis_range.dart';

abstract class AnalysisRepository {
  Future<AnalysisRange> getRange(String range);
}
