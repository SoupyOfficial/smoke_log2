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
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  showCheckboxColumn: false,
                  columnSpacing: constraints.maxWidth * 0.05,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Timestamp',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Mood',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Physical',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Length',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: tableData.map((record) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('yyyy-MM-dd')
                                    .format(record.timestamp.toDate()),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                DateFormat('hh:mma')
                                    .format(record.timestamp.toDate()),
                                style: TextStyle(
                                  fontSize: 15,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            record.moodRating.toString(),
                            style: TextStyle(
                              color: getColorForRatings(
                                  record.moodRating.toDouble()),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            record.physicalRating.toString(),
                            style: TextStyle(
                              color: getColorForRatings(
                                  record.physicalRating.toDouble()),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            record.length.toStringAsFixed(2),
                            style: TextStyle(
                              color: getColorForLength(record.length),
                            ),
                          ),
                        ),
                      ],
                      onSelectChanged: (selected) {
                        if (selected != null && selected) {
                          // Add interaction logic here if needed
                        }
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
