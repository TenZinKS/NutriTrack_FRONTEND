import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_macros_model.dart';

abstract class MacrosRemoteDatasource {
  Stream<UserMacrosModel> listenToMacros();
  Future<void> updateMacros(UserMacrosModel macros);
  Future<UserMacrosModel> fetchCurrentMacros();
  Future<void> markOnboardingCompleted();
  Future<bool> isOnboardingCompleted();
  Stream<bool> watchOnboardingStatus();
}

class MacrosRemoteDatasourceImpl implements MacrosRemoteDatasource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  MacrosRemoteDatasourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Stream<UserMacrosModel> listenToMacros() {
    final uid = _requireUser();
    final docRef = firestore.collection('users').doc(uid);

    final userId = uid;
    return docRef.snapshots().asyncMap((snapshot) async {
      if (!snapshot.exists) {
        await _initializeDoc(docRef, userId);
        final refreshed = await docRef.get();
        return UserMacrosModel.fromSnapshot(refreshed);
      }

      final data = snapshot.data() ?? {};
      final lastUpdated = data['macrosLastUpdatedDay'] as String?;
      if (lastUpdated != _todayKey()) {
        final macros = (data['macros'] as Map<String, dynamic>? ?? {});
        macros['caloriesConsumed'] = 0;
        macros['carbsConsumed'] = 0;
        macros['proteinConsumed'] = 0;
        macros['fatConsumed'] = 0;
        await docRef.set(
          {
            'macros': macros,
            'macrosLastUpdatedDay': _todayKey(),
          },
          SetOptions(merge: true),
        );
        final refreshed = await docRef.get();
        return UserMacrosModel.fromSnapshot(refreshed);
      }

      return UserMacrosModel.fromSnapshot(snapshot);
    });
  }

  @override
  Future<void> updateMacros(UserMacrosModel macros) async {
    final uid = _requireUser();
    final docRef = firestore.collection('users').doc(uid);

    await docRef.set(
      {
        'macros': macros.toMap(),
        'macrosLastUpdatedDay': _todayKey(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<UserMacrosModel> fetchCurrentMacros() async {
    final uid = _requireUser();
    final docRef = firestore.collection('users').doc(uid);
    var snapshot = await docRef.get();

    if (!snapshot.exists) {
      await _initializeDoc(docRef, uid);
      snapshot = await docRef.get();
    } else {
      final data = snapshot.data() ?? {};
      final lastUpdated = data['macrosLastUpdatedDay'] as String?;
      if (lastUpdated != _todayKey()) {
        final macros = (data['macros'] as Map<String, dynamic>? ?? {});
        macros['caloriesConsumed'] = 0;
        macros['carbsConsumed'] = 0;
        macros['proteinConsumed'] = 0;
        macros['fatConsumed'] = 0;
        await docRef.set(
          {
            'macros': macros,
            'macrosLastUpdatedDay': _todayKey(),
          },
          SetOptions(merge: true),
        );
        snapshot = await docRef.get();
      }
    }

    return UserMacrosModel.fromSnapshot(snapshot);
  }

  String _requireUser() {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _initializeDoc(
    DocumentReference<Map<String, dynamic>> docRef,
    String uid,
  ) async {
    await docRef.set({
      'macros': const UserMacrosModel(
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
      ).toMap(),
      'macrosLastUpdatedDay': _todayKey(),
      'uid': uid,
      'onboardingCompleted': false,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> markOnboardingCompleted() async {
    final uid = _requireUser();
    final docRef = firestore.collection('users').doc(uid);
    await docRef.set(
      {'onboardingCompleted': true},
      SetOptions(merge: true),
    );
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    final uid = _requireUser();
    final docRef = firestore.collection('users').doc(uid);
    var snapshot = await docRef.get();

    if (!snapshot.exists) {
      await _initializeDoc(docRef, uid);
      snapshot = await docRef.get();
    }

    final data = snapshot.data() ?? {};
    final value = data['onboardingCompleted'];
    if (value is bool) return value;
    return true;
  }

  @override
  Stream<bool> watchOnboardingStatus() {
    final uid = _requireUser();
    final docRef = firestore.collection('users').doc(uid);

    return docRef.snapshots().asyncMap((snapshot) async {
      if (!snapshot.exists) {
        await _initializeDoc(docRef, uid);
        final refreshed = await docRef.get();
        final data = refreshed.data() ?? {};
        final value = data['onboardingCompleted'];
        if (value is bool) return value;
        return true;
      }

      final data = snapshot.data() ?? {};
      final value = data['onboardingCompleted'];
      if (value is bool) return value;
      return true;
    });
  }
}
