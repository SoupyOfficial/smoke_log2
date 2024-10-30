// data_controller.dart
import 'package:fl_chart/fl_chart.dart';
import 'data_service.dart';
import 'data_utils.dart';
import 'inhalation_record.dart';
import 'app_config.dart';
import 'enums/chart_type.dart';
import 'enums/time_range.dart';
import 'thc_concentration.dart';


class DataController {
  final DataService dataService;
  final DataUtils dataUtils;
  String currentUser = 'Jacob';
  List<InhalationRecord> records = [];
  List<FlSpot> chartData = [];
  ChartType selectedChartType;
  TimeRange selectedRange;

  DataController({
    required this.dataService,
    required this.dataUtils,
    required this.selectedChartType,
    required this.selectedRange,
    });

  Future<void> initialize() async {
    await _updateCurrentUser();
    await fetchData();
  }

  Future<void> _updateCurrentUser() async {
    String collectionName = await AppConfig.getCollectionName();
    currentUser = collectionName.startsWith('Jacob') ? 'Jacob' : 'Ashley';
  }

  Future<void> fetchData() async {
    records = await dataUtils.fetchAllRecords();
    print('Fetched ${records.length} records.');
    chartData = getChartData(records);
    print('Generated chartData with ${chartData.length} points.');
  }

  List<FlSpot> getChartData(List<InhalationRecord> sortedData) {
    final Map<ChartType, Function> chartDataFunctions = {
      ChartType.cumulative: (data) => DataUtils.convertDataToChartData(
            data,
            selectedRange.value,
            const Duration(days: 1),
          ),
      ChartType.thcConcentration: (data) => DataUtils.calculateTHCConcentration(
            data,
            selectedRange.value,
            const Duration(days: 1),
          ),
      ChartType.rolling24h: (data) => DataUtils.convertDataToRollingChartData(
            data,
            selectedRange.value,
            const Duration(days: 1),
          ),
      ChartType.rolling30d: (data) => DataUtils.convertDataToRollingChartData(
            data,
            selectedRange.value,
            const Duration(days: 30),
          ),
      ChartType.rolling90d: (data) => DataUtils.convertDataToRollingChartData(
            data,
            selectedRange.value,
            const Duration(days: 90),
          ),
    };

    final function = chartDataFunctions[selectedChartType];

    if (function != null) {
      return function(sortedData);
    } else {
      return [];
    }
  }


}
