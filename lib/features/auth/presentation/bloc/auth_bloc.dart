import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_track/features/auth/domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase loginUsecase;

  AuthBloc({required this.loginUsecase}) : super(const AuthState()) {
    on<LoginEvent>(_login);
  }

  Future<void> _login(LoginEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final user = await loginUsecase(event.email, event.password);

      if (user != null) {
        emit(state.copyWith(status: AuthStatus.success));
      } else {
        emit(state.copyWith(status: AuthStatus.failure, message: "Invalid credentials"));
      }
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, message: e.toString()));
    }
  }
}
