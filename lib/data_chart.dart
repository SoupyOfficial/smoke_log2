// data_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'data_utils.dart';
import 'enums/time_range.dart';
import 'enums/chart_type.dart';

class DataChart extends StatelessWidget {
  final TimeRange timeRange;
  final ChartType chartType;
  final List<FlSpot> chartData;
  final double minY, maxY, minX, maxX;
  // Static data for testing
  static final testData = [
    FlSpot(1, 10),
    FlSpot(2, 20),
    FlSpot(3, 30),
  ];

  const DataChart({
    Key? key,
    required this.timeRange,
    required this.chartType,
    required this.chartData,
    required this.minY,
    required this.maxY,
    required this.minX,
    required this.maxX,
  }) : super(key: key);

  double calculateInterval(double minY, double maxY) {
    double range = maxY - minY;
    double interval = range / 6;
    print("Chart Data First: " + chartData.first.toString());
    print("Calculate Max Y: " +
        chartData.map((r) => r.y).reduce((a, b) => a > b ? a : b).toString());
    print("Max Y: " + maxY.toString());

    // Ensure interval is not zero or too small
    return interval > 0
        ? interval
        : 1.0; // Set to a default value like 1.0 if interval is zero
  }

  List<FlSpot> thinData(List<FlSpot> data, int step) {
    List<FlSpot> thinnedData = [];
    for (int i = 0; i < data.length; i += step) {
      thinnedData.add(data[i]);
    }
    return thinnedData;
  }

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return Center(
        child: Text(
          'No data available for the selected range.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    for (var spot in chartData) {
      if (!spot.x.isFinite || !spot.y.isFinite) {
        print("Invalid data point detected: $spot");
      }
    }
    chartData.sort((a, b) => a.x.compareTo(b.x));

    // print("Sorted Chart Data:");
    // chartData.forEach((spot) => print("x: ${spot.x}, y: ${spot.y}"));

    try {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: LineChart(LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: chartData,
              isCurved: false,
              // isCurved: chartType == 'thc_concentration' ? false : true,
              dotData: FlDotData(
                show: chartType !=
                    ChartType
                        .thcConcentration, // Dots are hidden only for THC Concentration
              ),
              color: Theme.of(context).highlightColor,
              barWidth: 4,
              belowBarData: BarAreaData(
                  show: true,
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.3)),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: calculateInterval(minY, maxY), // Dynamic interval
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: DataUtils.determineInterval(
                    timeRange), // Determine interval based on time range
                getTitlesWidget: (value, meta) {
                  if (value == chartData.last.x) {
                    return Container();
                  }
                  // Convert `value` to DateTime
                  final date =
                      DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  final formattedDate =
                      DateFormat('MMM dd').format(date); // Format as 'Jan 01'
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false), // Temporarily disable
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false), // Temporarily disable
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true),
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((touchedSpot) {
                  final date = DateTime.fromMillisecondsSinceEpoch(
                      touchedSpot.x.toInt());
                  final dateFormat = DateFormat('MMMM dd, HH:mm');
                  final formattedDate = dateFormat.format(date);
                  final value = touchedSpot.y.toStringAsFixed(2);
                  String label = '';

                  switch (chartType) {
                    case ChartType.cumulative:
                      label = 'Cumulative Usage';
                      break;
                    case ChartType.thcConcentration:
                      label = 'THC Concentration';
                      break;
                    case ChartType.rolling24h:
                      label = 'Rolling 24h Usage';
                      break;
                    case ChartType.rolling30d:
                      label = 'Rolling 30d Usage';
                      break;
                    case ChartType.rolling90d:
                      label = 'Rolling 90d Usage';
                      break;
                  }

                  return LineTooltipItem(
                    '$formattedDate\n$label: $value',
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  );
                }).toList();
              },
              tooltipPadding: const EdgeInsets.all(8.0),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
            ),
          ),
        )),
      );
    } catch (e, stackTrace) {
      print('Error building DataAnalysisPage: $e');
      print(stackTrace);
      return ErrorWidget('Something went wrong');
    }
  }
}
