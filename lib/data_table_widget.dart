import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'inhalation_record.dart';

class DataTableWidget extends StatelessWidget {
  final List<InhalationRecord> tableData;

  const DataTableWidget({super.key, required this.tableData});

  static Color getColorForLength(double length) {
    const double blueThreshold = 0.0;
    const double greenThreshold = 3.0;
    const double redThreshold = 18.0;
    const double purpleThreshold = 12.0;
    const double blackThreshold = 15.0;

    if (length <= blueThreshold) {
      return Colors.blue;
    } else if (length <= greenThreshold) {
      return Color.lerp(Colors.blue, Colors.green,
          (length - blueThreshold) / (greenThreshold - blueThreshold))!;
    } else if (length <= redThreshold) {
      return Color.lerp(Colors.green, Colors.red,
          (length - greenThreshold) / (redThreshold - greenThreshold))!;
    } else if (length <= purpleThreshold) {
      return Color.lerp(Colors.red, Colors.purple,
          (length - redThreshold) / (purpleThreshold - redThreshold))!;
    } else if (length <= blackThreshold) {
      return Color.lerp(Colors.purple, Colors.black,
          (length - purpleThreshold) / (blackThreshold - purpleThreshold))!;
    } else {
      return Colors.black;
    }
  }

  static Color getColorForRatings(double rating) {
    const double redThreshold = 2.0;
    const double purpleThreshold = 4.0;
    const double blueThreshold = 6.0;
    const double greenThreshold = 8.0;
    const double goldThreshold = 10.0;

    if (rating <= redThreshold) {
      return Colors.red;
    } else if (rating <= purpleThreshold) {
      return Color.lerp(Colors.red, Colors.purple,
          (rating - redThreshold) / (purpleThreshold - redThreshold))!;
    } else if (rating <= blueThreshold) {
      return Color.lerp(Colors.purple, Colors.blue,
          (rating - purpleThreshold) / (blueThreshold - purpleThreshold))!;
    } else if (rating <= greenThreshold) {
      return Color.lerp(Colors.blue, Colors.green,
          (rating - blueThreshold) / (greenThreshold - blueThreshold))!;
    } else if (rating <= goldThreshold) {
      return Color.lerp(Colors.green, Colors.yellow[600],
          (rating - greenThreshold) / (goldThreshold - greenThreshold))!;
    } else {
      return Colors.yellow[600]!;
    }
  }

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
                const DataColumn(label: Text('Time')),
                const DataColumn(label: Text('Mood')),
                const DataColumn(label: Text('Phys')),
                if (!isSmallScreen) const DataColumn(label: Text('Reason')),
                const DataColumn(
                    label: Text('Len', overflow: TextOverflow.ellipsis)),
              ],
              rows: tableData.map((data) {
                final timestamp = data.timestamp;
                final formattedTime = DateFormat(
                        isSmallScreen ? 'MM/dd HH:mm' : 'yyyy-MM-dd HH:mm:ss')
                    .format(timestamp.toDate());
                return DataRow(cells: [
                  DataCell(Text(
                    formattedTime,
                    style: const TextStyle(overflow: TextOverflow.ellipsis),
                  )),
                  DataCell(Text(
                    data.moodRating.toString(),
                    style: TextStyle(
                      color: getColorForRatings(data.moodRating.toDouble()),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
                  DataCell(Text(
                    data.physicalRating.toString(),
                    style: TextStyle(
                      color: getColorForRatings(data.physicalRating.toDouble()),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
                  if (!isSmallScreen)
                    DataCell(Text(
                      (data.reason as List<dynamic>).join(', '),
                      style: const TextStyle(overflow: TextOverflow.ellipsis),
                    )),
                  DataCell(Text(
                    data.length.toStringAsFixed(2),
                    style: TextStyle(
                      color: getColorForLength(data.length),
                      overflow: TextOverflow.ellipsis,
                    ),
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
