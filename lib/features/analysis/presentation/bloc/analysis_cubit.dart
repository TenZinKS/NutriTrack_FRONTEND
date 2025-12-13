import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/analysis_range.dart';
import '../../domain/usecases/get_analysis_range_usecase.dart';
import 'analysis_state.dart';

class AnalysisCubit extends Cubit<AnalysisState> {
  final GetAnalysisRangeUsecase getAnalysisRangeUsecase;

  AnalysisCubit({required this.getAnalysisRangeUsecase})
      : super(const AnalysisState());

  Future<void> loadRange(String range) async {
    emit(state.copyWith(status: AnalysisStatus.loading, range: range));
    try {
      final data = await getAnalysisRangeUsecase(range);
      emit(
        state.copyWith(
          status: AnalysisStatus.success,
          data: data,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AnalysisStatus.failure,
          message: e.toString(),
          data: AnalysisRange.empty,
        ),
      );
    }
  }
}
