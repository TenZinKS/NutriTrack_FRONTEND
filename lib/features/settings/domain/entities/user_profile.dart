import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String name;
  final String email;
  final String gender;
  final double heightCm;
  final double weightKg;

  const UserProfile({
    required this.name,
    required this.email,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
  });

  static const empty = UserProfile(
    name: '',
    email: '',
    gender: 'Male',
    heightCm: 0,
    weightKg: 0,
  );

  UserProfile copyWith({
    String? name,
    String? email,
    String? gender,
    double? heightCm,
    double? weightKg,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
    );
  }

  @override
  List<Object?> get props => [name, email, gender, heightCm, weightKg];
}
