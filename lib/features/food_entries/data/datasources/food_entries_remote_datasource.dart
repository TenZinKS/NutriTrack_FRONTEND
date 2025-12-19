import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/food_entry_model.dart';

abstract class FoodEntriesRemoteDatasource {
  Stream<List<FoodEntryModel>> listenTodayEntries();
  Future<FoodEntryModel> addEntry(FoodEntryModel entry);
  Future<void> updateEntry(FoodEntryModel entry);
  Future<void> deleteEntry(String id);
}

class FoodEntriesRemoteDatasourceImpl implements FoodEntriesRemoteDatasource {
  FoodEntriesRemoteDatasourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  @override
  Stream<List<FoodEntryModel>> listenTodayEntries() {
    final uid = _requireUser();
    final start = DateTime.now();
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final collection = firestore
        .collection('users')
        .doc(uid)
        .collection('food_entries')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('createdAt', descending: true);

    return collection.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => FoodEntryModel.fromDoc(doc.id, doc.data()))
          .toList(),
    );
  }

  @override
  Future<FoodEntryModel> addEntry(FoodEntryModel entry) async {
    final uid = _requireUser();
    final doc = firestore
        .collection('users')
        .doc(uid)
        .collection('food_entries')
        .doc();

    await doc.set(entry.toMap());
    final snapshot = await doc.get();
    return FoodEntryModel.fromDoc(snapshot.id, snapshot.data() ?? {});
  }

  @override
  Future<void> updateEntry(FoodEntryModel entry) async {
    final uid = _requireUser();
    final doc = firestore
        .collection('users')
        .doc(uid)
        .collection('food_entries')
        .doc(entry.id);

    await doc.set(entry.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteEntry(String id) async {
    final uid = _requireUser();
    await firestore
        .collection('users')
        .doc(uid)
        .collection('food_entries')
        .doc(id)
        .delete();
  }

  String _requireUser() {
    final user = firebaseAuth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }
}
