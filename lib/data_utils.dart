import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'thc_concentration.dart';
import 'inhalation_record.dart';
import 'data_service.dart';
import 'enums/time_range.dart';
import 'enums/chart_type.dart';

class DataUtils {
  final DataService dataService;

  DataUtils({required this.dataService});

  // Fetch all records using DataService
  Future<List<InhalationRecord>> fetchAllRecords() async {
    return await dataService.fetchAllRecords();
  }

  // Fetch records based on a specific date range
  Future<List<InhalationRecord>> fetchRecordsForDateRange(
      DateTime startDate, DateTime endDate) async {
    return await dataService.fetchRecordsByDateRange(startDate, endDate);
  }

  // Example: Fetch data for chart visualization based on range
  Future<List<FlSpot>> fetchDataForRange(String range) async {
    List<InhalationRecord> records = await fetchAllRecords();

    // Define the start date based on the range
    DateTime now = DateTime.now();
    DateTime startDate;
    if (range == 'week') {
      startDate = now.subtract(Duration(days: 7));
    } else if (range == 'month') {
      startDate = DateTime(now.year, now.month - 1, now.day);
    } else {
      startDate = DateTime(now.year);
    }

    // Filter records within the specified date range
    List<InhalationRecord> filteredRecords = records
        .where((record) => record.timestamp.toDate().isAfter(startDate))
        .toList();

    // Convert to chart data (FlSpot format)
    List<FlSpot> chartData = filteredRecords
        .map((record) => FlSpot(
              record.timestamp.toDate().millisecondsSinceEpoch.toDouble(),
              record.length,
            ))
        .toList();

    return chartData;
  }

  // Additional utility for calculating averages or other statistics
  double calculateAverageLength(List<InhalationRecord> records) {
    if (records.isEmpty) return 0.0;

    double totalLength =
        records.fold(0.0, (sum, record) => sum + record.length);
    return totalLength / records.length;
  }

  // Example: Fetch chart data within a custom date range
  Future<List<FlSpot>> fetchDataForCustomRange(
      DateTime startDate, DateTime endDate) async {
    List<InhalationRecord> records =
        await fetchRecordsForDateRange(startDate, endDate);

    // Convert to chart data (FlSpot format)
    List<FlSpot> chartData = records
        .map((record) => FlSpot(
              record.timestamp.toDate().millisecondsSinceEpoch.toDouble(),
              record.length,
            ))
        .toList();

    return chartData;
  }

  // Method for formatting the timestamp to display on the UI
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  static String formatDate(double value, TimeRange timeRange) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());

    switch (timeRange) {
      case TimeRange.week:
        return DateFormat('E').format(date); // Day of week
      case TimeRange.month:
      case TimeRange.threeMonths:
        return DateFormat('d MMM').format(date); // Day and month
      case TimeRange.sixMonths:
      case TimeRange.year:
        return DateFormat('MMM').format(date); // Month
    }
  }

  static double determineInterval(TimeRange timeRange) {
    switch (timeRange) {
      case TimeRange.week:
        return 86400000; // one day in milliseconds
      case TimeRange.month:
        return 2592000000 / 8; // one month in milliseconds divided by 30 days
      case TimeRange.threeMonths:
        return 7776000000 /
            9; // three months in milliseconds divided by 90 days
      case TimeRange.sixMonths:
        return 15552000000 /
            6; // six months in milliseconds divided by 180 days
      case TimeRange.year:
        return 31536000000 / 12; // one year in milliseconds divided by 365 days
      default:
        throw ArgumentError('Invalid time range selected');
    }
  }

  static List<FlSpot> convertDataToChartData(
      List<InhalationRecord> data, String selectedRange, Duration window) {
    Map<DateTime, double> cumulativeLengths = {};
    DateTime endDate = DateTime.now();
    DateTime startDate;
    int days = 7;

    switch (selectedRange) {
      case 'week':
        startDate = endDate.subtract(const Duration(days: 7));
        days = 7;
        break;
      case 'month':
        startDate = endDate.subtract(const Duration(days: 30));
        days = 30;
        break;
      case '3 months':
        startDate = endDate.subtract(const Duration(days: 90));
        days = 90;
        break;
      case '6 months':
        startDate = endDate.subtract(const Duration(days: 180));
        days = 180;
        break;
      case 'year':
        startDate = endDate.subtract(const Duration(days: 365));
        days = 365;
        break;
      default:
        throw ArgumentError('Invalid range selected');
    }

    for (var doc in data) {
      var timestamp = doc.timestamp.toDate();
      var date = DateTime(timestamp.year, timestamp.month, timestamp.day + 1)
          .subtract(const Duration(seconds: 1));
      var length = doc.length;

      if (!cumulativeLengths.containsKey(date)) {
        cumulativeLengths[date] = 0.0;
      }
      cumulativeLengths[date] = cumulativeLengths[date]! + length;
    }

    return cumulativeLengths.entries
        .where((entry) =>
            entry.key.isAfter(endDate.subtract(Duration(days: days))))
        .map((entry) {
      return FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), entry.value);
    }).toList();
  }

  static List<FlSpot> calculateTHCConcentration(
      List<InhalationRecord> data, String selectedRange, Duration window) {
    DateTime endDate = DateTime.now();
    DateTime startDate;
    int days = 7;

    // Determine the start date based on the selected range
    switch (selectedRange) {
      case 'week':
        startDate = endDate.subtract(const Duration(days: 7));
        days = 7;
        break;
      case 'month':
        startDate = endDate.subtract(const Duration(days: 30));
        days = 30;
        break;
      case '3 months':
        startDate = endDate.subtract(const Duration(days: 90));
        days = 90;
        break;
      case '6 months':
        startDate = endDate.subtract(const Duration(days: 180));
        days = 180;
        break;
      case '1 year':
        startDate = endDate.subtract(const Duration(days: 365));
        days = 365;
        break;
      default:
        throw ArgumentError('Invalid range selected');
    }

    // Create the THCConcentration object with default parameters and inhalations
    THCConcentration thcCalc = THCConcentration(inhalations: data);

    // Initialize the THC concentration list
    List<FlSpot> thcConcentrationData = [];

    // Step 1: Calculate THC at the start of every hour
    DateTime currentTime = DateTime(
        startDate.year, startDate.month, startDate.day, startDate.hour);
    while (currentTime.isBefore(endDate)) {
      double currentTimestamp = currentTime.millisecondsSinceEpoch.toDouble();

      // Calculate THC concentration at the start of the current hour
      double thcAtTime = thcCalc.calculateTHCAtTime(currentTimestamp);

      // Add the hourly result to the data list
      thcConcentrationData.add(FlSpot(currentTimestamp, thcAtTime * 1000000));

      // Move to the next hour
      currentTime = currentTime.add(const Duration(minutes: 1));
    }

    // // Step 2: Add actual inhalation occurrences with their timestamps
    // for (int i = 0; i < data.length; i++) {
    //   DateTime timestamp = (data[i]['timestamp'] as Timestamp).toDate();
    //   double currentTimestamp = timestamp.millisecondsSinceEpoch.toDouble();

    //   // Ensure that this timestamp is within the selected range
    //   if (timestamp.isAfter(startDate) && timestamp.isBefore(endDate)) {
    //     // Calculate THC concentration at the actual inhalation timestamp
    //     double thcAtInhalation = thcCalc.calculateTHCAtTime(currentTimestamp);

    //     // Add the actual occurrence to the data list
    //     thcConcentrationData
    //         .add(FlSpot(currentTimestamp, thcAtInhalation * 1000000));
    //   }
    // }

    // Sort the result by timestamp for proper chronological order
    thcConcentrationData.sort((a, b) => a.x.compareTo(b.x));

    return thcConcentrationData;
  }

  static List<FlSpot> convertDataToRollingChartData(
      List<InhalationRecord> data, String selectedRange, Duration window) {
    List<FlSpot> rollingChartData = [];
    DateTime endDate = DateTime.now();
    DateTime startDate;
    int days = 7;

    switch (selectedRange) {
      case 'week':
        startDate = endDate.subtract(const Duration(days: 7));
        days = 7;
        break;
      case 'month':
        startDate = endDate.subtract(const Duration(days: 30));
        days = 30;
        break;
      case '3 months':
        startDate = endDate.subtract(const Duration(days: 90));
        days = 90;
        break;
      case '6 months':
        startDate = endDate.subtract(const Duration(days: 180));
        days = 180;
        break;
      case '1 year':
        startDate = endDate.subtract(const Duration(days: 365));
        days = 365;
        break;
      default:
        throw ArgumentError('Invalid range selected');
    }

    // Filter data based on the selected range
    List<InhalationRecord> filteredData = data.where((entry) {
      var entryDate = entry.timestamp.toDate();
      return entryDate.isAfter(startDate.subtract(window)) &&
          entryDate.isBefore(endDate);
    }).toList();

    // Calculate rolling usage
    for (int i = 0; i < filteredData.length; i++) {
      var currentTimestamp = filteredData[i].timestamp.toDate();
      var rollingSum = 0.0;

      for (int j = i; j >= 0; j--) {
        var checkTimestamp = filteredData[j].timestamp.toDate();
        if (currentTimestamp.difference(checkTimestamp) <= window) {
          rollingSum += filteredData[j].length;
        } else {
          break;
        }
      }

      // Only add data points within the selected range
      if (currentTimestamp.isAfter(endDate.subtract(Duration(days: days)))) {
        rollingChartData.add(FlSpot(
            currentTimestamp.millisecondsSinceEpoch.toDouble(), rollingSum));
      }
    }

    return rollingChartData;
  }

  static List<FlSpot> convertDataToRollingChartData24h(
      List<InhalationRecord> data, String timeRange) {
    return convertDataToRollingChartData(data, timeRange, Duration(days: 1));
  }

  static List<FlSpot> convertDataToRollingChartData30d(
      List<InhalationRecord> data, String timeRange) {
    return convertDataToRollingChartData(data, timeRange, Duration(days: 30));
  }

  static List<FlSpot> convertDataToRollingChartData90d(
      List<InhalationRecord> data, String timeRange) {
    return convertDataToRollingChartData(data, timeRange, Duration(days: 90));
  }
}
