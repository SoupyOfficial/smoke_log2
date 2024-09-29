import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'data_utils.dart';

class DataChart extends StatelessWidget {
  final String timeRange;
  final String chartType;
  final List<FlSpot> chartData;
  final double minY, maxY, minX, maxX;

  const DataChart({
    super.key,
    required this.timeRange,
    required this.chartType,
    required this.chartData,
    required this.minY,
    required this.maxY,
    required this.minX,
    required this.maxX,
  });

  double calculateInterval(double minY, double maxY) {
    double range = maxY - minY;
    double interval = range / 6;

    // Ensure interval is not zero or too small
    return interval > 0
        ? interval
        : 1.0; // Set to a default value like 1.0 if interval is zero
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LineChart(LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: chartData,
            isCurved: true,
            // isCurved: chartType == 'thc_concentration' ? false : true,
            dotData: FlDotData(
              show: chartType == 'thc_concentration'
                  ? false
                  : true, // Disable the dots
            ),
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
              interval: DataUtils.determineInterval(
                  timeRange), // Determine interval based on time range
              getTitlesWidget: (value, meta) {
                if (value == chartData.last.x) {
                  return Container();
                }
                return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Transform.translate(
                      offset: const Offset(-10, 0),
                      child: Transform.rotate(
                        angle: -0.5, // Rotate labels for better readability
                        child: Text(
                          DataUtils.formatDate(value,
                              timeRange), // Format date based on time range
                        ),
                      ),
                    ));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if ((value - minY).abs() < 5 || (value - maxY).abs() < 5) {
                  return Container();
                }
                return Transform.translate(
                  offset: const Offset(-10, 0),
                  child: Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              interval: calculateInterval(minY, maxY), // Set dynamic interval
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
                final date =
                    DateTime.fromMillisecondsSinceEpoch(touchedSpot.x.toInt());
                final dateFormat = DateFormat('MMMM dd, HH:mm');
                final formattedDate = dateFormat.format(date);
                final value = touchedSpot.y.toStringAsFixed(2);
                String label = '';

                switch (chartType) {
                  case 'cumulative':
                    label = 'Cumulative Usage';
                  case 'thc_concentration':
                    label = 'THC Concentration';
                  case 'rolling_24h':
                    label = 'Rolling 24h Usage';
                  case 'rolling_30d':
                    label = 'Rolling 30d Usage';
                  case 'rolling_90d':
                    label = 'Rolling 90d Usage';
                  case 'default':
                    label = 'Total';
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
  }
}
