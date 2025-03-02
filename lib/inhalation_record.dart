import 'package:cloud_firestore/cloud_firestore.dart';

class InhalationRecord {
  final String id;
  final double length;
  final int moodRating;
  final int physicalRating;
  final List<String> reason;
  final Timestamp timestamp;

  InhalationRecord({
    required this.id,
    required this.length,
    required this.moodRating,
    required this.physicalRating,
    required this.reason,
    required this.timestamp,
  });

  // Factory method to create an InhalationRecord from Firestore data
  factory InhalationRecord.fromFirestore(Map<String, dynamic> data) {
    return InhalationRecord(
      id: data['id'],
      length: data['length'] ?? 0.0,
      moodRating: data['moodRating'] ?? 0,
      physicalRating: data['physicalRating'] ?? 0,
      reason: (data['reason'] is List)
          ? List<String>.from(data['reason'])
          : [data['reason']?.toString() ?? ''],
      timestamp: data['timestamp'] ?? null,
    );
  }

  // Method to convert an InhalationRecord to Firestore-compatible data
  Map<String, dynamic> toFirestore() {
    return {
      'length': length,
      'moodRating': moodRating,
      'physicalRating': physicalRating,
      'reason': reason,
      'timestamp': timestamp,
    };
  }
}
