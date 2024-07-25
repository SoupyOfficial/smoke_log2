import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_config.dart';

class DataStreamBuilder extends StatelessWidget {
  final Function(List<QueryDocumentSnapshot>) onData;

  const DataStreamBuilder({super.key, required this.onData});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: AppConfig.getCollectionName(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        String collectionName = snapshot.data!;
        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection(collectionName).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            var data = snapshot.data!.docs;
            return onData(data);
          },
        );
      },
    );
  }
}
