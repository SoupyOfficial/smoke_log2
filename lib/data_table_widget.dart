import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'inhalation_record.dart';

class DataTableWidget extends StatelessWidget {
  final List<InhalationRecord> tableData;

  const DataTableWidget({super.key, required this.tableData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Length')),
              DataColumn(label: Text('Mood Rating')),
              DataColumn(label: Text('Physical Rating')),
              DataColumn(label: Text('Reason')),
              DataColumn(label: Text('Timestamp')),
            ],
            rows: tableData.map((data) {
              final timestamp = data.timestamp;
              final formattedTime =
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate());
              return DataRow(cells: [
                DataCell(Text(data.length.toString())),
                DataCell(Text(data.moodRating.toString())),
                DataCell(Text(data.physicalRating.toString())),
                DataCell(Text((data.reason as List<dynamic>).join(', '))),
                DataCell(Text(formattedTime)),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
