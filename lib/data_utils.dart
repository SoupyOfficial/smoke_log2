import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'inhalation_record.dart';
import 'data_service.dart';

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

  static String formatDate(double value, String range) {
    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    switch (range) {
      case 'week':
        return DateFormat('MM/dd').format(date);
      case 'month':
      case '3 months':
      case '6 months':
        return DateFormat('MM/dd').format(date);
      case 'year':
        return DateFormat('MM/yyyy').format(date);
      default:
        return DateFormat('MM/dd').format(date);
    }
  }

  static double determineInterval(String range) {
    switch (range) {
      case 'week':
        return 86400000; // one day in milliseconds
      case 'month':
        return 2592000000 / 8; // one month in milliseconds divided by 30 days
      case '3 months':
        return 7776000000 /
            9; // three months in milliseconds divided by 90 days
      case '6 months':
        return 15552000000 /
            6; // six months in milliseconds divided by 180 days
      case 'year':
        return 31536000000 / 12; // one year in milliseconds divided by 365 days
      default:
        return 86400000; // default to one day
    }
  }
}
