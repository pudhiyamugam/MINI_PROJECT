import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Search by registration number
  Future<List<Map<String, dynamic>>> searchByRegNo(String query) async {
    final snapshot = await _firestore
        .collection('seats')
        .where('reg_no', isGreaterThanOrEqualTo: query.toUpperCase())
        .where('reg_no', isLessThan: '${query.toUpperCase()}z')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Search by room number
  Future<List<Map<String, dynamic>>> searchByRoom(String room) async {
    final snapshot = await _firestore
        .collection('seats')
        .where('room', isEqualTo: room.trim())
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}