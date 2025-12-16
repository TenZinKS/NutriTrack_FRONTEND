import 'package:nutri_track/features/dashboard/domain/entities/user_macros.dart';

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

  @override
  Future<void> syncWithMacros(
    UserMacros macros, {
    required int deltaCalories,
    required int deltaProtein,
    required int deltaCarbs,
    required int deltaFat,
  }) {
    return remoteDatasource.syncWithMacros(
      macros,
      deltaCalories: deltaCalories,
      deltaProtein: deltaProtein,
      deltaCarbs: deltaCarbs,
      deltaFat: deltaFat,
    );
  }
}
