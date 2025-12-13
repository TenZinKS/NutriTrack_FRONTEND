import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/analysis_range_model.dart';

abstract class AnalysisRemoteDatasource {
  Future<AnalysisRangeModel> fetchRange(String range);
}

class AnalysisRemoteDatasourceImpl implements AnalysisRemoteDatasource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  AnalysisRemoteDatasourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<AnalysisRangeModel> fetchRange(String range) async {
    final uid = firebaseAuth.currentUser?.uid;
    if (uid == null) {
      return AnalysisRangeModel.empty();
    }

    final docRef = firestore
        .collection('users')
        .doc(uid)
        .collection('analysis')
        .doc(range.toLowerCase());

    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      return AnalysisRangeModel.empty();
    }

    final data = snapshot.data();
    if (data == null) {
      return AnalysisRangeModel.empty();
    }

    return AnalysisRangeModel.fromMap(data);
  }
}
