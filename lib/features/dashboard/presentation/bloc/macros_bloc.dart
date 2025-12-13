import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_macros.dart';
import '../../domain/usecases/listen_user_macros_usecase.dart';
import '../../domain/usecases/update_user_macros_usecase.dart';
import 'macros_event.dart';
import 'macros_state.dart';

class MacrosBloc extends Bloc<MacrosEvent, MacrosState> {
  final ListenUserMacrosUsecase listenUserMacrosUsecase;
  final UpdateUserMacrosUsecase updateUserMacrosUsecase;
  StreamSubscription<UserMacros>? _subscription;

  MacrosBloc({
    required this.listenUserMacrosUsecase,
    required this.updateUserMacrosUsecase,
  }) : super(const MacrosState()) {
    on<LoadMacrosEvent>(_onLoadMacros);
    on<MacrosChangedEvent>(_onMacrosChanged);
    on<MacrosStreamErrorEvent>(_onStreamError);
    on<SubmitMacrosUpdateEvent>(_onSubmitMacros);
  }

  Future<void> _onLoadMacros(
    LoadMacrosEvent event,
    Emitter<MacrosState> emit,
  ) async {
    emit(state.copyWith(status: MacrosStatus.loading));
    await _subscription?.cancel();

    _subscription = listenUserMacrosUsecase().listen(
      (macros) => add(MacrosChangedEvent(macros)),
      onError: (error) => add(MacrosStreamErrorEvent(error.toString())),
    );
  }

  void _onMacrosChanged(
    MacrosChangedEvent event,
    Emitter<MacrosState> emit,
  ) {
    emit(
      state.copyWith(
        status: MacrosStatus.success,
        macros: event.macros,
        clearMessage: true,
      ),
    );
  }

  void _onStreamError(
    MacrosStreamErrorEvent event,
    Emitter<MacrosState> emit,
  ) {
    emit(state.copyWith(
      status: MacrosStatus.failure,
      message: event.message,
    ));
  }

  Future<void> _onSubmitMacros(
    SubmitMacrosUpdateEvent event,
    Emitter<MacrosState> emit,
  ) async {
    emit(state.copyWith(status: MacrosStatus.updating));
    try {
      await updateUserMacrosUsecase(event.macros);
      emit(state.copyWith(status: MacrosStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: MacrosStatus.failure,
        message: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
