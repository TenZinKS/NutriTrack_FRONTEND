class UserMacros {
  final String uid;
  final String name;
  final int caloriesGoal;
  final int caloriesConsumed;
  final int carbsGoal;
  final int carbsConsumed;
  final int proteinGoal;
  final int proteinConsumed;
  final int fatGoal;
  final int fatConsumed;
  final int waterGoal;
  final int waterConsumed;

  const UserMacros({
    required this.uid,
    required this.name,
    required this.caloriesGoal,
    required this.caloriesConsumed,
    required this.carbsGoal,
    required this.carbsConsumed,
    required this.proteinGoal,
    required this.proteinConsumed,
    required this.fatGoal,
    required this.fatConsumed,
    required this.waterGoal,
    required this.waterConsumed,
  });

  UserMacros copyWith({
    String? uid,
    String? name,
    int? caloriesGoal,
    int? caloriesConsumed,
    int? carbsGoal,
    int? carbsConsumed,
    int? proteinGoal,
    int? proteinConsumed,
    int? fatGoal,
    int? fatConsumed,
    int? waterGoal,
    int? waterConsumed,
  }) {
    return UserMacros(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      caloriesGoal: caloriesGoal ?? this.caloriesGoal,
      caloriesConsumed: caloriesConsumed ?? this.caloriesConsumed,
      carbsGoal: carbsGoal ?? this.carbsGoal,
      carbsConsumed: carbsConsumed ?? this.carbsConsumed,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      proteinConsumed: proteinConsumed ?? this.proteinConsumed,
      fatGoal: fatGoal ?? this.fatGoal,
      fatConsumed: fatConsumed ?? this.fatConsumed,
      waterGoal: waterGoal ?? this.waterGoal,
      waterConsumed: waterConsumed ?? this.waterConsumed,
    );
  }

  factory UserMacros.empty() {
    return const UserMacros(
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
    );
  }
}
