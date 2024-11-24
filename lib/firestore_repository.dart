import 'package:cloud_firestore/cloud_firestore.dart';
import 'inhalation_record.dart'; // Assuming this file now contains the InhalationRecord class

class FirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all records from Firestore
  Future<List<InhalationRecord>> fetchRecords(String collectionName) async {
    final QuerySnapshot snapshot =
        await _firestore.collection(collectionName).get();

    return snapshot.docs.map((doc) {
      return InhalationRecord.fromFirestore(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // Add a new record to Firestore
  Future<void> addRecord(String collectionName, InhalationRecord record) async {
    await _firestore.collection(collectionName).add(record.toFirestore());
  }

  // Update a record in Firestore by its ID
  Future<void> updateRecord(String collectionName, String docId,
      InhalationRecord updatedRecord) async {
    await _firestore
        .collection(collectionName)
        .doc(docId)
        .update(updatedRecord.toFirestore());
  }

  // Delete a record in Firestore by its ID
  Future<void> deleteRecord(String collectionName, String docId) async {
    await _firestore.collection(collectionName).doc(docId).delete();
  }
}
