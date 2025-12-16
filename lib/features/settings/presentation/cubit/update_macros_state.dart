part of 'update_macros_cubit.dart';

enum UpdateMacrosStatus { initial, loading, ready, submitting, success, failure }

class UpdateMacrosState {
  final UpdateMacrosStatus status;
  final UserMacros? baseMacros;
  final int caloriesGoal;
  final int carbsGoal;
  final int proteinGoal;
  final int fatGoal;
  final int waterGoal;
  final String? message;

  const UpdateMacrosState({
    this.status = UpdateMacrosStatus.initial,
    this.baseMacros,
    this.caloriesGoal = 0,
    this.carbsGoal = 0,
    this.proteinGoal = 0,
    this.fatGoal = 0,
    this.waterGoal = 0,
    this.message,
  });

  UpdateMacrosState copyWith({
    UpdateMacrosStatus? status,
    UserMacros? baseMacros,
    int? caloriesGoal,
    int? carbsGoal,
    int? proteinGoal,
    int? fatGoal,
    int? waterGoal,
    String? message,
  }) {
    return UpdateMacrosState(
      status: status ?? this.status,
      baseMacros: baseMacros ?? this.baseMacros,
      caloriesGoal: caloriesGoal ?? this.caloriesGoal,
      carbsGoal: carbsGoal ?? this.carbsGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      fatGoal: fatGoal ?? this.fatGoal,
      waterGoal: waterGoal ?? this.waterGoal,
      message: message,
    );
  }
}
