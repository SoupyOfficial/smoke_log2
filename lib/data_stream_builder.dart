// In data_stream_builder.dart
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_config.dart';

class DataStreamBuilder extends StatefulWidget {
  final Widget Function(List<QueryDocumentSnapshot>) builder;

  const DataStreamBuilder({super.key, required this.builder});

  @override
  _DataStreamBuilderState createState() => _DataStreamBuilderState();
}

class _DataStreamBuilderState extends State<DataStreamBuilder> {
  Stream<QuerySnapshot>? _stream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  Future<void> _initStream() async {
    String collectionName = await AppConfig.getCollectionName();
    setState(() {
      _stream =
          FirebaseFirestore.instance.collection(collectionName).snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_stream == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var data = snapshot.data!.docs;
        // Only build the widget when all documents have IDs
        if (data.every((doc) => doc.id.isNotEmpty)) {
          return widget.builder(data);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
