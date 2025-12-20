import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile_model.dart';

abstract class UserProfileRemoteDatasource {
  Future<UserProfileModel> fetchProfile();
  Future<void> updateProfile(UserProfileModel profile);
}

class UserProfileRemoteDatasourceImpl implements UserProfileRemoteDatasource {
  UserProfileRemoteDatasourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  @override
  Future<UserProfileModel> fetchProfile() async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final docRef = firestore.collection('users').doc(user.uid);
    var snapshot = await docRef.get();
    if (!snapshot.exists) {
      await docRef.set(
        {
          'uid': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
        },
        SetOptions(merge: true),
      );
      snapshot = await docRef.get();
    }

    return UserProfileModel.fromSnapshot(
      snapshot,
      fallbackName: user.displayName ?? '',
      fallbackEmail: user.email ?? '',
    );
  }

  @override
  Future<void> updateProfile(UserProfileModel profile) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final docRef = firestore.collection('users').doc(user.uid);
    if (profile.email.isNotEmpty && profile.email != user.email) {
      await user.verifyBeforeUpdateEmail(profile.email);
    }
    await docRef.set(profile.toMap(), SetOptions(merge: true));

    if (user.displayName != profile.name) {
      await user.updateDisplayName(profile.name);
    }
  }
}
