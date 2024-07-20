import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'data_utils.dart';

class DataChart extends StatelessWidget {
  final List<FlSpot> chartData;
  final double minY, maxY, minX, maxX;

  const DataChart(
      {super.key,
      required this.chartData,
      required this.minY,
      required this.maxY,
      required this.minX,
      required this.maxX});

  @override
  Widget build(BuildContext context) {
    // return Expanded(
    // flex: 1,
    // child:
    return Padding(
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
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
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
                        angle: -0.5, // Rotate labels for better readability
                        child: Text(
                          DateFormat('MM/dd').format(
                            DateTime.fromMillisecondsSinceEpoch(value.toInt()),
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
              reservedSize: 25,
              getTitlesWidget: (value, meta) {
                if ((value - minY).abs() < 5 || (value - maxY).abs() < 5) {
                  return Container();
                }
                return Transform.translate(
                  offset: const Offset(0, 0),
                  child: Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 10),
                  ),
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
              showTitles: false, // Hide labels on the top side if necessary
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
                final date =
                    DateTime.fromMillisecondsSinceEpoch(touchedSpot.x.toInt());
                final dateFormat = DateFormat('MMMM dd');
                final formattedDate = dateFormat.format(date);
                final inhalationLength = touchedSpot.y.toStringAsFixed(2);
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
                      text: DataUtils.getOrdinalSuffix(touchedSpot.x),
                      style: const TextStyle(
                          color: Colors.white,
                          fontFeatures: [FontFeature.superscripts()]),
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
    );
    // );
  }
}
