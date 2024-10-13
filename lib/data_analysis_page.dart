import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smoke_log2/app_config.dart';
import 'custom_app_bar.dart';
import 'data_chart.dart';
import 'data_table_widget.dart';
import 'data_service.dart';
import 'data_utils.dart';
import 'inhalation_record.dart';

class DataAnalysisPage extends StatefulWidget {
  final Function onReload;

  const DataAnalysisPage({required this.onReload, super.key});

  @override
  _DataAnalysisPageState createState() => _DataAnalysisPageState();
}

class _DataAnalysisPageState extends State<DataAnalysisPage> {
  String _selectedRange = 'week';
  String _selectedChartType = 'thc_concentration';
  String _currentUser = 'Jacob';
  late DataUtils _dataUtils;
  List<InhalationRecord> _records = [];
  List<FlSpot> _chartData = [];
  bool _isLoading = true; // Add a loading state

  @override
  void initState() {
    super.initState();
    print('DataAnalysisPage initState called');

    // Update the current user based on the collection name
    _updateCurrentUser();

    // Initialize DataUtils and then fetch data
    _initializeDataUtils().then((_) {
      _fetchData();
    }).catchError((e) {
      print('Error initializing DataUtils: $e');
    });
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

  Future<void> _initializeDataUtils() async {
    print('Initializing DataUtils...');

    // Fetch the actual collection name asynchronously
    String collectionName = await AppConfig
        .getCollectionName(); // Make sure this method fetches the collection name

    print('Fetched collection name: $collectionName');

    // Set up DataService and DataUtils with the correct collection name
    DataService dataService = DataService(collectionName: collectionName);
    _dataUtils = DataUtils(dataService: dataService);
  }

  Future<void> _fetchData() async {
    print('Fetching data...');
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      List<InhalationRecord> records = await _dataUtils.fetchAllRecords();
      List<FlSpot> chartData =
          await _dataUtils.fetchDataForRange(_selectedRange);

      print('Records fetched: ${records.length}');
      print('Chart data fetched: ${chartData.length}');

      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          _records = records;
          _chartData = _getChartData(records);
          _isLoading = false; // Stop loading
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false; // Stop loading even if there's an error
        });
      }
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Column(
              children: [
                _buildDropdowns(),
                Expanded(
                  child: DataChart(
                    timeRange: _selectedRange,
                    chartType: _selectedChartType,
                    chartData: _chartData,
                    minY: 0,
                    maxY: _chartData.isNotEmpty
                        ? _chartData
                                .map((r) => r.y)
                                .reduce((a, b) => a > b ? a : b) *
                            1.5
                        : 0,
                    minX: _chartData.isNotEmpty ? _chartData.first.x : 0,
                    maxX: _chartData.isNotEmpty ? _chartData.last.x : 1,
                  ),
                ),
                Expanded(
                  child: DataTableWidget(
                    tableData: _records,
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

  List<FlSpot> _getChartData(List<InhalationRecord> sortedData) {
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
}
