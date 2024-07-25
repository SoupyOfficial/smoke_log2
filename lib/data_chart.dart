import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'data_utils.dart';
import 'package:intl/intl.dart';

/* TODO:
  Chart Ideas:
    Rolling Usage Last 24H: For each record we calculate the usage for the last 24 hours and display tha value for the records timestamp

    Previous Range Overlay: For each selection (let's say week) we show the cumulative usage per day (or rolling) for the curent week and the cumulative usage for the previous week overlayed in the background somehow (maybe different color or greyed out)
*/
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FlSpot>>(
      future: DataUtils.fetchDataForRange(
          timeRange), // Fetch data based on the time range
      builder: (context, snapshot) {
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
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3)),
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
                    final label = chartType == 'cumulative'
                        ? 'Cumulative Usage'
                        : 'Rolling 24h Usage';
                    return LineTooltipItem(
                      '$formattedDate\n$label: $value',
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    );
                  }).toList();
                },
              ),
            ),
          )),
        );
      },
    );
  }
}
