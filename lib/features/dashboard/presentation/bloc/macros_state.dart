import '../../domain/entities/user_macros.dart';

enum MacrosStatus { initial, loading, success, failure, updating }

class MacrosState {
  final MacrosStatus status;
  final UserMacros macros;
  final String? message;

  const MacrosState({
    this.status = MacrosStatus.initial,
    this.macros = const UserMacros(
      uid: '',
      name: '',
      caloriesGoal: 2000,
      caloriesConsumed: 0,
      carbsGoal: 200,
      carbsConsumed: 0,
      proteinGoal: 120,
      proteinConsumed: 0,
      fatGoal: 70,
      fatConsumed: 0,
      waterGoal: 2000,
      waterConsumed: 0,
    ),
    this.message,
  });

  MacrosState copyWith({
    MacrosStatus? status,
    UserMacros? macros,
    String? message,
    bool clearMessage = false,
  }) {
    return MacrosState(
      status: status ?? this.status,
      macros: macros ?? this.macros,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}
