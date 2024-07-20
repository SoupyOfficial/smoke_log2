import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataStreamBuilder extends StatelessWidget {
  final Function(List<QueryDocumentSnapshot>) onData;

  const DataStreamBuilder({super.key, required this.onData});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('JacobLogs').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var data = snapshot.data!.docs;
        return onData(data);
      },
    );
  }
}
