import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRemoteDatasource {
  Future login(String email, String password);
  Future<void> register(String name, String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<User?> currentUser();
  Future<void> logout();
  Future<void> deleteAccount();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDatasourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future login(String email, String password) async {
    return firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> register(String name, String email, String password) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      await user.updateDisplayName(name);
      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'onboardingCompleted': false,
        'macros': {
          'caloriesGoal': 2000,
          'caloriesConsumed': 0,
          'carbsGoal': 200,
          'carbsConsumed': 0,
          'proteinGoal': 120,
          'proteinConsumed': 0,
          'fatGoal': 70,
          'fatConsumed': 0,
          'waterGoal': 2000,
          'waterConsumed': 0,
        },
      });
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<User?> currentUser() async {
    return firebaseAuth.currentUser;
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    await user.delete();
  }
}
