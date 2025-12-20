import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.name,
    required super.email,
    required super.gender,
    required super.heightCm,
    required super.weightKg,
  });

  factory UserProfileModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot, {
    required String fallbackName,
    required String fallbackEmail,
  }) {
    final data = snapshot.data() ?? {};
    return UserProfileModel(
      name: (data['name'] ?? fallbackName) as String? ?? '',
      email: (data['email'] ?? fallbackEmail) as String? ?? '',
      gender: (data['gender'] ?? 'Male') as String? ?? 'Male',
      heightCm: ((data['heightCm'] ?? 0) as num).toDouble(),
      weightKg: ((data['weightKg'] ?? 0) as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'profileUpdatedAt': FieldValue.serverTimestamp(),
    };
  }
}
