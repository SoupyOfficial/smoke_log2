// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'custom_app_bar.dart';
import 'app_config.dart';
import 'data_chart.dart';
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
  Stream<QuerySnapshot>? _dataStream;

  @override
  void initState() {
    super.initState();
    _updateCurrentUser();
  }

  Future<void> _updateCurrentUser() async {
    String collectionName = await AppConfig.getCollectionName();
    setState(() {
      _currentUser = collectionName.startsWith('Jacob') ? 'Jacob' : 'Ashley';
      _dataStream =
          FirebaseFirestore.instance.collection(collectionName).snapshots();
    });
  }

  Future<void> _swapUser() async {
    await AppConfig.swapUser(widget.onReload);
    await _updateCurrentUser();
  }

  String _getUsageText(String value) {
    switch (value) {
      case 'cumulative':
        return 'Cumulative Usage';
      case 'thc_concentration':
        return 'Decay Rate';
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
          _buildDropdowns(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _dataStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('No data available'));
                }
                final data = snapshot.data!.docs.map((doc) {
                  final docData = doc.data() as Map<String, dynamic>;
                  docData['id'] = doc.id;
                  return docData;
                }).toList();
                return _buildDataView(data);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdowns() {
    return Padding(
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
            items: <String>['week', 'month', '3 months', '6 months', 'year']
                .map<DropdownMenuItem<String>>((String value) {
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
              'thc_concentration',
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
    );
  }

  Widget _buildDataView(List<Map<String, dynamic>> data) {
    var filteredData =
        DataUtils.filterDataForRange(data, _selectedRange, _selectedChartType);
    var sortedData = DataUtils.sortDataByTimestamp(filteredData);

    return Column(
      children: [
        _buildChart(sortedData),
        _buildTable(sortedData),
      ],
    );
  }

  Widget _buildChart(List<Map<String, dynamic>> sortedData) {
    var chartData = _getChartData(sortedData);

    if (chartData.isEmpty) {
      return const Center(
          child: Text("No data available for the selected range."));
    }

    double minY =
        chartData.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    double maxY =
        chartData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    double minX = chartData.first.x;
    double maxX = chartData.last.x;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.3,
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
        child: DataChart(
          timeRange: _selectedRange,
          chartType: _selectedChartType,
          chartData: chartData,
          minY: _selectedChartType == 'cumulative' ? 0 : minY,
          maxY: maxY,
          minX: minX,
          maxX: maxX,
        ),
      ),
    );
  }

  List<FlSpot> _getChartData(List<Map<String, dynamic>> sortedData) {
    switch (_selectedChartType) {
      case 'cumulative':
        return DataUtils.convertDataToChartData(
            sortedData, _selectedRange, const Duration(days: 1));
      case 'thc_concentration':
        return DataUtils.calculateTHCConcentration(
            sortedData, _selectedRange, const Duration(days: 1));
      case 'rolling_24h':
        return DataUtils.convertDataToRollingChartData(
            sortedData, _selectedRange, const Duration(days: 1));
      case 'rolling_30d':
        return DataUtils.convertDataToRollingChartData(
            sortedData, _selectedRange, const Duration(days: 30));
      case 'rolling_90d':
        return DataUtils.convertDataToRollingChartData(
            sortedData, _selectedRange, const Duration(days: 90));
      default:
        return [];
    }
  }

  Widget _buildTable(List<Map<String, dynamic>> data) {
    var tableData = DataUtils.convertDataToTableData(data);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
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
        child: DataTableWidget(tableData: tableData),
      ),
    );
  }
}
