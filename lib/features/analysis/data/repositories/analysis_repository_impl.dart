import '../../domain/entities/analysis_range.dart';
import '../../domain/repositories/analysis_repository.dart';
import '../datasources/analysis_remote_datasource.dart';

class AnalysisRepositoryImpl implements AnalysisRepository {
  final AnalysisRemoteDatasource remoteDatasource;

  AnalysisRepositoryImpl({required this.remoteDatasource});

  @override
  Future<AnalysisRange> getRange(String range) {
    return remoteDatasource.fetchRange(range);
  }
}
