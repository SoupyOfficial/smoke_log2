import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DataUtils {
  static List<FlSpot> convertDataToChartData(List<QueryDocumentSnapshot> data) {
    Map<DateTime, double> cumulativeLengths = {};
    for (var doc in data) {
      var timestamp = (doc['timestamp'] as Timestamp).toDate();
      var date = DateTime(timestamp.year, timestamp.month, timestamp.day + 1)
          .subtract(const Duration(seconds: 1));
      var length = doc['length'] as double;

      if (!cumulativeLengths.containsKey(date)) {
        cumulativeLengths[date] = 0.0;
      }
      cumulativeLengths[date] = cumulativeLengths[date]! + length;
    }

    return cumulativeLengths.entries.map((entry) {
      return FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), entry.value);
    }).toList();
  }

  static List<QueryDocumentSnapshot> filterDataForLastWeek(
      List<QueryDocumentSnapshot> data) {
    final now = DateTime.now();
    final oneWeekAgo = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 7));
    return data.where((doc) {
      var timestamp = (doc['timestamp'] as Timestamp).toDate();
      return timestamp.isAfter(oneWeekAgo);
    }).toList();
  }

  static List<QueryDocumentSnapshot> sortDataByTimestamp(
      List<QueryDocumentSnapshot> data) {
    data.sort((a, b) {
      var aTimestamp = (a['timestamp'] as Timestamp).toDate();
      var bTimestamp = (b['timestamp'] as Timestamp).toDate();
      return aTimestamp.compareTo(bTimestamp);
    });
    return data;
  }

  static List<Map<String, dynamic>> convertDataToTableData(
      List<QueryDocumentSnapshot> data) {
    return data.map((doc) {
      return {
        'timestamp': doc['timestamp'] as Timestamp,
        'mood':
            doc['moodRating'] as int, // Assuming mood is stored as an integer
        'physical': doc['physicalRating']
            as int, // Assuming physical is stored as an integer
        'length': doc['length'] as double,
      };
    }).toList();
  }

  static String formatDateWithOrdinalSuffix(DateTime date) {
    final day = date.day;
    String suffix;

    if (day >= 11 && day <= 13) {
      suffix = 'th';
    } else {
      switch (day % 10) {
        case 1:
          suffix = 'st';
          break;
        case 2:
          suffix = 'nd';
          break;
        case 3:
          suffix = 'rd';
          break;
        default:
          suffix = 'th';
      }
    }

    final dateFormat = DateFormat('MMMM d');
    return '${dateFormat.format(date)}<sup>$suffix</sup>';
  }

  static String getOrdinalSuffix(double timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    final day = date.day;
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
