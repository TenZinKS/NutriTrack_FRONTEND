import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase? loginUsecase;
  final ForgotPasswordUsecase? forgotPasswordUsecase;
  final RegisterUsecase? registerUsecase;

  AuthBloc({
    this.loginUsecase,
    this.forgotPasswordUsecase,
    this.registerUsecase,
  }) : super(const AuthState()) {
    on<LoginEvent>(_onLogin);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<RegisterEvent>(_onRegister);
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (loginUsecase == null) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        message: "Login is not configured",
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await loginUsecase!(event.email, event.password);
      emit(state.copyWith(status: AuthStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        message: e.toString(),
      ));
    }
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (forgotPasswordUsecase == null) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        message: "Forgot password is not configured",
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await forgotPasswordUsecase!(event.email);
      emit(state.copyWith(
        status: AuthStatus.success,
        message: "Reset link sent to your email",
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        message: e.toString(),
      ));
    }
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (registerUsecase == null) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        message: "Registration is not configured",
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await registerUsecase!(event.name, event.email, event.password);
      emit(state.copyWith(
        status: AuthStatus.success,
        message: "Account created successfully",
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        message: e.toString(),
      ));
    }
  }
}
