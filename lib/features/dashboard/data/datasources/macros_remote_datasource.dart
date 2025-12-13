import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_macros_model.dart';

abstract class MacrosRemoteDatasource {
  Stream<UserMacrosModel> listenToMacros();
  Future<void> updateMacros(UserMacrosModel macros);
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

    return docRef.snapshots().map(
      (snapshot) => UserMacrosModel.fromSnapshot(snapshot),
    );
  }

  @override
  Future<void> updateMacros(UserMacrosModel macros) async {
    final uid = _requireUser();
    final docRef = firestore.collection('users').doc(uid);

    await docRef.set({'macros': macros.toMap()}, SetOptions(merge: true));
  }

  String _requireUser() {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }
}
