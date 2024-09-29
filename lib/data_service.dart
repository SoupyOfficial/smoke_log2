import 'package:cloud_firestore/cloud_firestore.dart';
import 'inhalation_record.dart';

class DataService {
  final String collectionName;

  DataService({required this.collectionName});

  // Fetch all records from Firestore and convert them to InhalationRecord objects
  Future<List<InhalationRecord>> fetchAllRecords() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection(collectionName).get();

    print("Fetched ${snapshot.docs.length} records from Firestore...  \n");
    if (snapshot.docs.isNotEmpty) {
      print("First record: ${snapshot.docs.first.data()}");
    }

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return InhalationRecord.fromFirestore(data);
    }).toList();
  }

  // Fetch records based on a specific date range and return them as InhalationRecord objects
  Future<List<InhalationRecord>> fetchRecordsByDateRange(
      DateTime start, DateTime end) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .where('timestamp', isGreaterThanOrEqualTo: start)
        .where('timestamp', isLessThanOrEqualTo: end)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return InhalationRecord.fromFirestore(data);
    }).toList();
  }
}
