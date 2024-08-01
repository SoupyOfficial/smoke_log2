import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'custom_app_bar.dart';
import 'app_config.dart';
import 'data_chart.dart';
import 'data_stream_builder.dart';
import 'data_table_widget.dart';
import 'data_utils.dart';

class DataAnalysisPage extends StatefulWidget {
  final Function onReload;

  const DataAnalysisPage({required this.onReload, super.key});

  @override
  _DataAnalysisPageState createState() => _DataAnalysisPageState();
}

class _DataAnalysisPageState extends State<DataAnalysisPage> {
  String _selectedRange = 'week';
  String _selectedChartType = 'cumulative';
  String _currentUser = 'Jacob';

  @override
  void initState() {
    super.initState();
    _updateCurrentUser();
  }

  Future<void> _updateCurrentUser() async {
    String collectionName = await AppConfig.getCollectionName();
    setState(() {
      _currentUser = collectionName.startsWith('Jacob') ? 'Jacob' : 'Ashley';
    });
  }

  Future<void> _swapUser() async {
    await AppConfig.swapUser(widget.onReload);
    await _updateCurrentUser();
    setState(() {}); // Trigger a rebuild to refresh the data
  }

  String _getUsageText(String value) {
    switch (value) {
      case 'cumulative':
        return 'Cumulative Usage';
      case 'rolling_24h':
        return 'Rolling 24h Usage';
      case 'rolling_30d':
        return 'Rolling 30 Days Usage';
      case 'rolling_90d':
        return 'Rolling 90 Days Usage';
      default:
        return 'Unknown Usage';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '$_currentUser\'s Data Analysis',
        onSwapUser: _swapUser,
        onReload: widget.onReload,
      ),
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
                  items: <String>[
                    'cumulative',
                    'rolling_24h',
                    'rolling_30d',
                    'rolling_90d'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(_getUsageText(value)),
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
                var filteredData = DataUtils.filterDataForRange(
                    data, _selectedRange, _selectedChartType);
                var sortedData = DataUtils.sortDataByTimestamp(filteredData);

                var chartData;

                switch (_selectedChartType) {
                  case 'cumulative':
                    chartData = DataUtils.convertDataToChartData(sortedData);
                  case 'rolling_24h':
                    chartData = DataUtils.convertDataToRollingChartData(
                        sortedData, _selectedRange, const Duration(days: 1));
                  case 'rolling_30d':
                    chartData = DataUtils.convertDataToRollingChartData(
                        sortedData, _selectedRange, const Duration(days: 30));
                  case 'rolling_90d':
                    chartData = DataUtils.convertDataToRollingChartData(
                        sortedData, _selectedRange, const Duration(days: 90));
                }
                var tableData = DataUtils.convertDataToTableData(sortedData);

                if (chartData.isEmpty) {
                  return const Center(
                      child: Text("No data available for the selected range."));
                }

                double minY = chartData
                    .map((spot) => spot.y)
                    .reduce((a, b) => a < b ? a : b);
                double actualMaxY = chartData
                    .map((spot) => spot.y)
                    .reduce((a, b) => a > b ? a : b);
                double avgY =
                    chartData.map((spot) => spot.y).reduce((a, b) => a + b) /
                        chartData.length;
                double possibleMaxY1 = actualMaxY + 10;
                double possibleMaxY2 = 2 * avgY;
                double maxY =
                    (possibleMaxY1 > actualMaxY && possibleMaxY2 > actualMaxY)
                        ? (possibleMaxY1 < possibleMaxY2
                            ? possibleMaxY1
                            : possibleMaxY2)
                        : actualMaxY + 10;
                minY = (minY - 10).floorToDouble();
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
                              minY:
                                  _selectedChartType == 'cumulative' ? 0 : minY,
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
