import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_config.dart';

class DataStreamBuilder extends StatefulWidget {
  final Function(List<QueryDocumentSnapshot>) onData;

  const DataStreamBuilder({Key? key, required this.onData}) : super(key: key);

  @override
  _DataStreamBuilderState createState() => _DataStreamBuilderState();
}

class _DataStreamBuilderState extends State<DataStreamBuilder> {
  late Stream<QuerySnapshot> _stream;

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
    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var data = snapshot.data!.docs;
        return widget.onData(data);
      },
    );
  }
}
