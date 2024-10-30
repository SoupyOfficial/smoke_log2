// data_analysis_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smoke_log2/app_config.dart';
import 'custom_app_bar.dart';
import 'data_service.dart';
import 'data_utils.dart';
import 'inhalation_record.dart';
import 'data_controller.dart';
import 'custom_app_bar.dart';
import 'data_chart.dart';
import 'data_table_widget.dart';
import 'time_range_dropdown.dart';
import 'chart_type_dropdown.dart';
import 'enums/time_range.dart';
import 'enums/chart_type.dart';

class DataAnalysisPage extends StatefulWidget {
  final Function onReload;

  const DataAnalysisPage({required this.onReload, Key? key}) : super(key: key);

  @override
  _DataAnalysisPageState createState() => _DataAnalysisPageState();
}

class _DataAnalysisPageState extends State<DataAnalysisPage> {
  late DataController _dataController;
  bool _isLoading = true;
  TimeRange _selectedRange = TimeRange.week;
  ChartType _selectedChartType = ChartType.thcConcentration;
  String _currentUser = 'Jacob';
  List<InhalationRecord> _records = [];
  List<FlSpot> _chartData = [];

  @override
  void initState() {
    super.initState();
    _initializeDataController();
  }

  Future<void> _initializeDataController() async {
    // Initialize DataService and DataUtils
    String collectionName = await AppConfig.getCollectionName();
    DataService dataService = DataService(collectionName: collectionName);
    DataUtils dataUtils = DataUtils(dataService: dataService);

    _dataController = DataController(
      dataService: dataService,
      dataUtils: dataUtils,
      selectedChartType: _selectedChartType,
      selectedRange: _selectedRange
    );

    await _dataController.initialize();

    if (mounted) {
      setState(() {
        _isLoading = false;
    _chartData = _dataController.chartData;
    _records = _dataController.records;
    _isLoading = false;
      });
    }
  }

  Future<void> _swapUser() async {
    await AppConfig.swapUser(widget.onReload);
    await _dataController.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  // data_analysis_page.dart
  Widget _buildDropdowns() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TimeRangeDropdown(
            selectedRange: _selectedRange,
            onChanged: (newValue) {
              setState(() {
                _selectedRange = newValue!;
              });
            },
          ),
          ChartTypeDropdown(
            selectedChartType: _selectedChartType,
            onChanged: (newValue) {
              setState(() {
                _selectedChartType = newValue!;
            });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  print('Building DataAnalysisPage...');
  print('Chart data length: ${_chartData.length}');
  print('First chart data point: ${_chartData.isNotEmpty ? _chartData.first : 'No Data'}');
  print('Last chart data point: ${_chartData.isNotEmpty ? _chartData.last : 'No Data'}');

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

  // The rest of your UI code remains mostly unchanged
}
