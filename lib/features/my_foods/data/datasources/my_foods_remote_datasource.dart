import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/custom_food_model.dart';

abstract class MyFoodsRemoteDatasource {
  Future<void> saveCustomFood(Map<String, dynamic> data);
  Stream<List<CustomFoodModel>> listenCustomFoods();
  Future<void> toggleFavorite(String id, bool isFavorite);
  Future<void> deleteCustomFood(String id);
}

class MyFoodsRemoteDatasourceImpl implements MyFoodsRemoteDatasource {
  MyFoodsRemoteDatasourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  @override
  Future<void> saveCustomFood(Map<String, dynamic> data) async {
    final uid = firebaseAuth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not authenticated');
    }

    await firestore
        .collection('users')
        .doc(uid)
        .collection('customFoods')
        .add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'isFavorite': false,
    });
  }

  @override
  Stream<List<CustomFoodModel>> listenCustomFoods() {
    final uid = firebaseAuth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return firestore
        .collection('users')
        .doc(uid)
        .collection('customFoods')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(CustomFoodModel.fromDoc).toList(),
        );
  }

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final uid = firebaseAuth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not authenticated');
    }
    final doc = firestore
        .collection('users')
        .doc(uid)
        .collection('customFoods')
        .doc(id);
    await doc.update({'isFavorite': isFavorite});
  }

  @override
  Future<void> deleteCustomFood(String id) async {
    final uid = firebaseAuth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not authenticated');
    }
    await firestore
        .collection('users')
        .doc(uid)
        .collection('customFoods')
        .doc(id)
        .delete();
  }
}
