part of 'welcome_goals_cubit.dart';

enum WelcomeGoalsStatus { initial, loading, ready, submitting, success, failure }

class WelcomeGoalsState {
  final WelcomeGoalsStatus status;
  final UserMacros? baseMacros;
  final int caloriesGoal;
  final int carbsGoal;
  final int proteinGoal;
  final int fatGoal;
  final int waterGoal;
  final String? message;

  const WelcomeGoalsState({
    this.status = WelcomeGoalsStatus.initial,
    this.baseMacros,
    this.caloriesGoal = 2000,
    this.carbsGoal = 200,
    this.proteinGoal = 120,
    this.fatGoal = 70,
    this.waterGoal = 2000,
    this.message,
  });

  WelcomeGoalsState copyWith({
    WelcomeGoalsStatus? status,
    UserMacros? baseMacros,
    int? caloriesGoal,
    int? carbsGoal,
    int? proteinGoal,
    int? fatGoal,
    int? waterGoal,
    String? message,
  }) {
    return WelcomeGoalsState(
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
