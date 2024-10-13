import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smoke_log2/inhalation_record.dart';

class RollingUsage {
  List<InhalationRecord> inhalations;

  RollingUsage({required this.inhalations});

  List<FlSpot> convertDataToRollingChartData(
      List<InhalationRecord> data, String selectedRange, Duration window) {
    List<FlSpot> rollingChartData = [];
    DateTime endDate = DateTime.now();
    DateTime startDate;
    int days;

    switch (selectedRange) {
      case '1 week':
        startDate = endDate.subtract(const Duration(days: 7));
        days = 7;
        break;
      case '1 month':
        startDate = endDate.subtract(const Duration(days: 30));
        days = 30;
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

    List<InhalationRecord> filteredData = data.where((entry) {
      DateTime entryDate = (entry.timestamp as Timestamp).toDate();
      return entryDate.isAfter(startDate) && entryDate.isBefore(endDate);
    }).toList();

    Map<DateTime, double> cumulativeLengthPerDay = {};
    for (var record in filteredData) {
      DateTime dayKey = DateTime(record.timestamp.toDate().year,
          record.timestamp.toDate().month, record.timestamp.toDate().day);
      cumulativeLengthPerDay.update(dayKey, (value) => value + record.length,
          ifAbsent: () => record.length);
    }

    for (int i = 0; i < days; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      DateTime dayKey =
          DateTime(currentDate.year, currentDate.month, currentDate.day);
      double cumulativeLength = cumulativeLengthPerDay[dayKey] ?? 0.0;
      rollingChartData.add(FlSpot(i.toDouble(), cumulativeLength));
    }

    return rollingChartData;
  }
}
