import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class DataUtils {
  static var collectionName = kReleaseMode ? 'JacobLogs' : 'JacobLogsTest';

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
        'id': doc.id,
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
