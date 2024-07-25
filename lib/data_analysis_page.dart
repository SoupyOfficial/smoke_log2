import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'data_analysis_app_bar.dart';
import 'data_chart.dart';
import 'data_stream_builder.dart';
import 'data_table_widget.dart';
import 'data_utils.dart';

class DataAnalysisPage extends StatefulWidget {
  const DataAnalysisPage({super.key});

  @override
  _DataAnalysisPageState createState() => _DataAnalysisPageState();
}

class _DataAnalysisPageState extends State<DataAnalysisPage> {
  String _selectedRange = 'week';
  String _selectedChartType = 'cumulative';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DataAnalysisAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedRange,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRange = newValue!;
                    });
                  },
                  items: <String>[
                    'week',
                    'month',
                    '3 months',
                    '6 months',
                    'year'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                DropdownButton<String>(
                  value: _selectedChartType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedChartType = newValue!;
                    });
                  },
                  items: <String>['cumulative', 'rolling']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value == 'cumulative'
                          ? 'Cumulative Usage'
                          : 'Rolling 24h Usage'),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: DataStreamBuilder(
              onData: (List<QueryDocumentSnapshot<Object?>> snapshotDocs) {
                // Convert QueryDocumentSnapshot to Map<String, dynamic>
                var data = snapshotDocs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();
                var filteredData =
                    DataUtils.filterDataForRange(data, _selectedRange);
                var sortedData = DataUtils.sortDataByTimestamp(filteredData);

                var chartData = _selectedChartType == 'cumulative'
                    ? DataUtils.convertDataToChartData(sortedData)
                    : DataUtils.convertDataToRollingChartData(sortedData);
                var tableData = DataUtils.convertDataToTableData(sortedData);

                if (chartData.isEmpty) {
                  return const Center(
                      child: Text("No data available for the selected range."));
                }

                double minY = chartData
                    .map((spot) => spot.y)
                    .reduce((a, b) => a < b ? a : b);
                double possibleMaxY = chartData
                        .map((spot) => spot.y)
                        .reduce((a, b) => a > b ? a : b) +
                    10;
                double avgY =
                    chartData.map((spot) => spot.y).reduce((a, b) => a + b) /
                        chartData.length;
                double maxY = 2 * avgY > possibleMaxY ? 2 * avgY : possibleMaxY;
                minY = minY.floorToDouble();
                maxY = maxY.ceilToDouble();
                DateTime firstDate = DateTime.fromMillisecondsSinceEpoch(
                    chartData.first.x.toInt());
                DateTime adjustedFirstDate =
                    DateTime(firstDate.year, firstDate.month, firstDate.day + 1)
                        .subtract(const Duration(seconds: 1));
                double minX =
                    adjustedFirstDate.millisecondsSinceEpoch.toDouble();

                DateTime lastDate = DateTime.fromMillisecondsSinceEpoch(
                    chartData.last.x.toInt());
                DateTime adjustedLastDate =
                    DateTime(lastDate.year, lastDate.month, lastDate.day + 1)
                        .subtract(const Duration(seconds: 1));
                double maxX =
                    adjustedLastDate.millisecondsSinceEpoch.toDouble();

                return Column(
                  children: [
                    Padding(
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
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.20,
                          child: DataChart(
                              timeRange: _selectedRange,
                              chartType: _selectedChartType,
                              chartData: chartData,
                              minY: 0,
                              maxY: maxY,
                              minX: minX,
                              maxX: maxX),
                        ),
                      ),
                    ),
                    Padding(
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
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.50,
                          child: DataTableWidget(tableData: tableData),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
