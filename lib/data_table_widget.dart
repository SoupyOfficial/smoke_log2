import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'inhalation_record.dart';

class DataTableWidget extends StatelessWidget {
  final List<InhalationRecord> tableData;

  const DataTableWidget({super.key, required this.tableData});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: isSmallScreen ? 10 : null,
              columns: [
                const DataColumn(
                    label: Text('Len', overflow: TextOverflow.ellipsis)),
                const DataColumn(label: Text('Mood')),
                const DataColumn(label: Text('Phys')),
                if (!isSmallScreen) const DataColumn(label: Text('Reason')),
                const DataColumn(label: Text('Time')),
              ],
              rows: tableData.map((data) {
                final timestamp = data.timestamp;
                final formattedTime = DateFormat(
                        isSmallScreen ? 'MM/dd HH:mm' : 'yyyy-MM-dd HH:mm:ss')
                    .format(timestamp.toDate());
                return DataRow(cells: [
                  DataCell(SizedBox(
                    width: 50, // Set fixed width for Length column
                    child: Text(data.length.toStringAsFixed(2),
                        overflow: TextOverflow.ellipsis),
                  )),
                  DataCell(SizedBox(
                    width: 40, // Set fixed width for Mood column
                    child: Text(data.moodRating.toString(),
                        overflow: TextOverflow.ellipsis),
                  )),
                  DataCell(SizedBox(
                    width: 40, // Set fixed width for Physical column
                    child: Text(data.physicalRating.toString(),
                        overflow: TextOverflow.ellipsis),
                  )),
                  if (!isSmallScreen)
                    DataCell(SizedBox(
                      width: isSmallScreen
                          ? 100
                          : 200, // Adjust Reason column width
                      child: Text((data.reason as List<dynamic>).join(', '),
                          overflow: TextOverflow.ellipsis),
                    )),
                  DataCell(SizedBox(
                    width: 120, // Set fixed width for Timestamp column
                    child: Text(formattedTime, overflow: TextOverflow.ellipsis),
                  )),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
