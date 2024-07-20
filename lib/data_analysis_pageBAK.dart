import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'data_utils.dart';

class DataAnalysisPage extends StatelessWidget {
  const DataAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Analysis'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('JacobLogs').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var data = snapshot.data!.docs;
          var filteredData = DataUtils.filterDataForLastWeek(data);
          var sortedData = DataUtils.sortDataByTimestamp(filteredData);
          var chartData = DataUtils.convertDataToChartData(sortedData);
          var tableData = DataUtils.convertDataToTableData(sortedData);

          // Calculate minY and maxY dynamically
          double minY =
              chartData.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
          double maxY =
              chartData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

          // Rounding minY and maxY to the nearest integers
          minY = minY.floorToDouble();
          maxY = maxY.ceilToDouble();

          // Get the first x value and adjust it to 11:59:59 PM of the previous day
          DateTime firstDate =
              DateTime.fromMillisecondsSinceEpoch(chartData.first.x.toInt());
          DateTime adjustedFirstDate =
              DateTime(firstDate.year, firstDate.month, firstDate.day + 1)
                  .subtract(Duration(seconds: 1));
          double minX = adjustedFirstDate.millisecondsSinceEpoch.toDouble();

          DateTime lastDate =
              DateTime.fromMillisecondsSinceEpoch(chartData.last.x.toInt());
          DateTime adjustedLastDate =
              DateTime(lastDate.year, lastDate.month, lastDate.day + 1)
                  .subtract(Duration(seconds: 1));
          double maxX = adjustedLastDate.millisecondsSinceEpoch.toDouble();

          return Column(
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LineChart(LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartData,
                        isCurved: true,
                        color: Theme.of(context).highlightColor,
                        barWidth: 4,
                        belowBarData: BarAreaData(
                            show: true,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3)),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 86400000, // one day in milliseconds
                          getTitlesWidget: (value, meta) {
                            if (value == maxX) {
                              return Container();
                            }
                            return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Transform.translate(
                                  offset: const Offset(-10, 0),
                                  child: Transform.rotate(
                                    angle:
                                        -0.5, // Rotate labels for better readability
                                    child: Text(
                                      DateFormat('MM/dd').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            value.toInt()),
                                      ),
                                    ),
                                  ),
                                ));
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            if ((value - minY).abs() < 1) {
                              return Container();
                            }
                            return Text(
                              value.toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                          interval: 10, // Set a fixed interval
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false, // Hide labels on the right side
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles:
                              false, // Hide labels on the top side if necessary
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    gridData: const FlGridData(show: false),
                    minX: minX,
                    maxX: null,
                    minY: minY,
                    maxY: maxY,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        // tooltipBorder: Colors.blueAccent,
                        fitInsideVertically:
                            true, // Ensure the tooltip fits inside the chart vertically
                        fitInsideHorizontally:
                            true, // Ensure the tooltip fits inside the chart horizontally

                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((touchedSpot) {
                            final date = DateTime.fromMillisecondsSinceEpoch(
                                touchedSpot.x.toInt());
                            final dateFormat = DateFormat('MMMM dd');
                            final formattedDate = dateFormat.format(date);
                            final inhalationLength =
                                touchedSpot.y.toStringAsFixed(2);
                            return LineTooltipItem(
                              '',
                              TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface), // Default style for the text
                              children: [
                                TextSpan(
                                  text: formattedDate,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                TextSpan(
                                  text:
                                      DataUtils.getOrdinalSuffix(touchedSpot.x),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFeatures: [
                                        FontFeature.superscripts()
                                      ]),
                                ),
                                TextSpan(
                                  text: '\nLength: $inhalationLength',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    ),
                  )),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Table(
                      border: TableBorder.all(),
                      columnWidths: const {
                        0: FlexColumnWidth(2.5),
                        1: FlexColumnWidth(1.1667),
                        2: FlexColumnWidth(1.1667),
                        3: FlexColumnWidth(1.1667),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface),
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Timestamp',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Mood',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Physical',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Length',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        ...tableData.reversed.map((item) {
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(DateFormat('yyyy-MM-dd @ kk:mm')
                                    .format(item['timestamp'].toDate())),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(item['mood'].toString()),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(item['physical'].toString()),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(item['length'].toStringAsFixed(2)),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
