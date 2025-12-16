import 'package:nutri_track/features/dashboard/domain/entities/user_macros.dart';

import '../entities/analysis_range.dart';

abstract class AnalysisRepository {
  Future<AnalysisRange> getRange(String range);
  Future<void> syncWithMacros(
    UserMacros macros, {
    required int deltaCalories,
    required int deltaProtein,
    required int deltaCarbs,
    required int deltaFat,
  });
}
