import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DataUtils {
  static var collectionName = kReleaseMode ? 'JacobLogs' : 'JacobLogsTest';

  static Future<List<Map<String, dynamic>>> fetchDataFromFirestore() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection(collectionName).get();
    final data =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    return data;
  }

  static Future<List<FlSpot>> fetchDataForRange(String range) async {
    // Fetch data from Firestore and filter based on the selected range
    final data = await fetchDataFromFirestore();
    final now = DateTime.now();
    final filteredData = data.where((entry) {
      final timestamp = DateTime.fromMillisecondsSinceEpoch(entry['timestamp']);
      switch (range) {
        case 'week':
          return timestamp.isAfter(now.subtract(Duration(days: 7)));
        case 'month':
          return timestamp.isAfter(now.subtract(Duration(days: 30)));
        case '3 months':
          return timestamp.isAfter(now.subtract(Duration(days: 90)));
        case '6 months':
          return timestamp.isAfter(now.subtract(Duration(days: 180)));
        case 'year':
          return timestamp.isAfter(now.subtract(Duration(days: 365)));
        default:
          return false;
      }
    }).toList();

    return filteredData.map((entry) {
      return FlSpot(entry['timestamp'].toDouble(), entry['value'].toDouble());
    }).toList();
  }

  static List<Map<String, dynamic>> filterDataForRange(
      List<Map<String, dynamic>> data, String range) {
    final now = DateTime.now();
    return data.where((entry) {
      final timestamp = (entry['timestamp'] as Timestamp).toDate();
      switch (range) {
        case 'week':
          return timestamp.isAfter(now.subtract(Duration(days: 7)));
        case 'month':
          return timestamp.isAfter(now.subtract(Duration(days: 30)));
        case '3 months':
          return timestamp.isAfter(now.subtract(Duration(days: 90)));
        case '6 months':
          return timestamp.isAfter(now.subtract(Duration(days: 180)));
        case 'year':
          return timestamp.isAfter(now.subtract(Duration(days: 365)));
        default:
          return false;
      }
    }).toList();
  }

  static List<Map<String, dynamic>> sortDataByTimestamp(
      List<Map<String, dynamic>> data) {
    data.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
    return data;
  }

  static List<FlSpot> convertDataToChartData(List<Map<String, dynamic>> data) {
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

  static List<Map<String, dynamic>> calculateRollingWeek(
      List<Map<String, dynamic>> data) {
    List<Map<String, dynamic>> rollingWeekData = [];

    for (int i = 0; i < data.length; i++) {
      DateTime currentTimestamp = DateTime.parse(data[i]['timestamp']);
      DateTime startTimestamp = currentTimestamp.subtract(Duration(hours: 24));

      double rollingSum = 0;

      for (int j = 0; j <= i; j++) {
        DateTime timestamp = DateTime.parse(data[j]['timestamp']);
        if (timestamp.isAfter(startTimestamp) &&
            timestamp.isBefore(currentTimestamp)) {
          rollingSum += data[j]['length'];
        }
      }

      rollingWeekData.add({
        'timestamp': data[i]['timestamp'],
        'rolling_length': rollingSum,
      });
    }

    return rollingWeekData;
  }

  static List<Map<String, dynamic>> convertDataToTableData(
      List<Map<String, dynamic>> data) {
    return data.map((doc) {
      return {
        'timestamp': doc['timestamp'] as Timestamp,
        'mood': doc['moodRating'] != null ? doc['moodRating'] as int : -1,
        'physical':
            doc['physicalRating'] != null ? doc['physicalRating'] as int : -1,
        'length': doc['length'] as double,
        'id': doc['id'],
      };
    }).toList();
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

  // Function to calculate rolling usage
  List<Map<String, dynamic>> calculateRollingUsage(
      List<QueryDocumentSnapshot> data, Duration window) {
    List<Map<String, dynamic>> rollingUsage = [];
    for (int i = 0; i < data.length; i++) {
      DateTime currentTime = (data[i]['timestamp'] as Timestamp).toDate();
      double usageSum = 0;
      for (int j = i; j >= 0; j--) {
        DateTime checkTime = (data[j]['timestamp'] as Timestamp).toDate();
        if (currentTime.difference(checkTime) <= window) {
          usageSum += data[j]['length'];
        } else {
          break;
        }
      }
      rollingUsage.add({'timestamp': currentTime, 'rollingUsage': usageSum});
    }
    return rollingUsage;
  }

  static List<FlSpot> convertDataToRollingChartData(
      List<Map<String, dynamic>> data) {
    List<FlSpot> rollingChartData = [];
    for (int i = 0; i < data.length; i++) {
      var currentTimestamp = (data[i]['timestamp'] as Timestamp).toDate();
      var rollingSum = 0.0;

      for (int j = i; j >= 0; j--) {
        var checkTimestamp = (data[j]['timestamp'] as Timestamp).toDate();
        if (currentTimestamp.difference(checkTimestamp).inHours <= 24) {
          rollingSum += data[j]['length'] as double;
        } else {
          break;
        }
      }

      rollingChartData.add(FlSpot(
          currentTimestamp.millisecondsSinceEpoch.toDouble(), rollingSum));
    }
    return rollingChartData;
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

  static String getOrdinalSuffix(double value) {
    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    int day = date.day;
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

  static Color getColorForLength(double length) {
    // Define the breakpoints for the gradient
    const double blueThreshold = 0.0;
    const double greenThreshold = 3.0;
    const double redThreshold = 18.0;
    const double purpleThreshold = 12.0;
    const double blackThreshold = 15.0;

    // Map length to a gradient color
    if (length <= blueThreshold) {
      return Colors.blue;
    } else if (length <= greenThreshold) {
      return Color.lerp(Colors.blue, Colors.green,
          (length - blueThreshold) / (greenThreshold - blueThreshold))!;
    } else if (length <= redThreshold) {
      return Color.lerp(Colors.green, Colors.red,
          (length - greenThreshold) / (redThreshold - greenThreshold))!;
    } else if (length <= purpleThreshold) {
      return Color.lerp(Colors.red, Colors.purple,
          (length - redThreshold) / (purpleThreshold - redThreshold))!;
    } else if (length <= blackThreshold) {
      return Color.lerp(Colors.purple, Colors.black,
          (length - purpleThreshold) / (blackThreshold - purpleThreshold))!;
    } else {
      return Colors.black;
    }
  }

  static Color getColorForRatings(double length) {
    // Define the breakpoints for the gradient
    const double redThreshold = 2.0;
    const double purpleThreshold = 4.0;
    const double blueThreshold = 6.0;
    const double greenThreshold = 8.0;
    const double goldThreshold = 10.0;

    // Map length to a gradient color
    if (length <= redThreshold) {
      return Colors.red;
    } else if (length <= purpleThreshold) {
      return Color.lerp(Colors.red, Colors.purple,
          (length - redThreshold) / (purpleThreshold - redThreshold))!;
    } else if (length <= blueThreshold) {
      return Color.lerp(Colors.purple, Colors.blue,
          (length - purpleThreshold) / (blueThreshold - purpleThreshold))!;
    } else if (length <= greenThreshold) {
      return Color.lerp(Colors.blue, Colors.green,
          (length - blueThreshold) / (greenThreshold - blueThreshold))!;
    } else if (length <= goldThreshold) {
      return Color.lerp(Colors.green, Colors.yellow[600],
          (length - greenThreshold) / (goldThreshold - greenThreshold))!;
    } else {
      return Colors.yellow[600]!;
    }
  }

  static void showEditPopup(
      BuildContext context, Map<String, dynamic> rowData) {
    TextEditingController moodController =
        TextEditingController(text: rowData['mood'].toString());
    TextEditingController physicalController =
        TextEditingController(text: rowData['physical'].toString());
    TextEditingController lengthController = TextEditingController(
        text: (rowData['length'] as double).toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Record',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: moodController,
                    decoration: InputDecoration(
                      labelText: 'Mood',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: physicalController,
                    decoration: InputDecoration(
                      labelText: 'Physical',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: lengthController,
                    decoration: InputDecoration(
                      labelText: 'Length',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).primaryColor, // Background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('Confirm'),
              onPressed: () {
                // Update the record in Firebase
                FirebaseFirestore.instance
                    .collection(collectionName)
                    .doc(rowData['id'].toString())
                    .update({
                  'moodRating': int.parse(moodController.text),
                  'physicalRating': int.parse(physicalController.text),
                  'length': double.parse(lengthController.text),
                }).then((value) {
                  Navigator.of(context).pop();
                }).catchError((error) {
                  // Handle the error
                  print('Error updating record: $error');
                });
              },
            ),
          ],
        );
      },
    );
  }
}
