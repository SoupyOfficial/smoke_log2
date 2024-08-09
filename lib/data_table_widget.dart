import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'data_utils.dart';

class DataTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> tableData;

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
                  rows: tableData.reversed.map((row) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('yyyy-MM-dd')
                                    .format(row['timestamp'].toDate()),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                DateFormat('hh:mma')
                                    .format(row['timestamp'].toDate()),
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
                            row['mood'].toString(),
                            style: TextStyle(
                              color: DataUtils.getColorForRatings(
                                  (row['mood'] as num).toDouble()),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            row['physical'].toString(),
                            style: TextStyle(
                              color: DataUtils.getColorForRatings(
                                  (row['physical'] as num).toDouble()),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            row['length'].toStringAsFixed(2),
                            style: TextStyle(
                              color: DataUtils.getColorForLength(
                                  (row['length'] as num).toDouble()),
                            ),
                          ),
                        ),
                        // DataCell(Container(
                        //   width: 0,
                        //   child: Text(row['id']),
                        // ))
                      ],
                      onSelectChanged: (selected) {
                        if (selected != null && selected) {
                          DataUtils.showEditPopup(context, row);
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
