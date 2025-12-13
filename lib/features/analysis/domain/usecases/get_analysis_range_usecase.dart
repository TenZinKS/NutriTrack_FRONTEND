import '../entities/analysis_range.dart';
import '../repositories/analysis_repository.dart';

class GetAnalysisRangeUsecase {
  final AnalysisRepository repository;

  GetAnalysisRangeUsecase(this.repository);

  Future<AnalysisRange> call(String range) {
    return repository.getRange(range);
  }
}
