import 'package:flutter/material.dart';

import 'data_analysis_app_bar.dart';
import 'data_chart.dart';
import 'data_stream_builder.dart';
import 'data_table_widget.dart';
import 'data_utils.dart';

class DataAnalysisPage extends StatelessWidget {
  const DataAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DataAnalysisAppBar(),
      body: DataStreamBuilder(
        onData: (data) {
          var filteredData = DataUtils.filterDataForLastWeek(data);
          var sortedData = DataUtils.sortDataByTimestamp(filteredData);
          var chartData = DataUtils.convertDataToChartData(sortedData);
          var tableData = DataUtils.convertDataToTableData(sortedData);

          double minY =
              chartData.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
          double avgY =
              chartData.map((spot) => spot.y).reduce((a, b) => a + b) /
                  chartData.length;
          double maxY = 2 * avgY;
          minY = minY.floorToDouble();
          maxY = maxY.ceilToDouble();
          DateTime firstDate =
              DateTime.fromMillisecondsSinceEpoch(chartData.first.x.toInt());
          DateTime adjustedFirstDate =
              DateTime(firstDate.year, firstDate.month, firstDate.day + 1)
                  .subtract(const Duration(seconds: 1));
          double minX = adjustedFirstDate.millisecondsSinceEpoch.toDouble();

          DateTime lastDate =
              DateTime.fromMillisecondsSinceEpoch(chartData.last.x.toInt());
          DateTime adjustedLastDate =
              DateTime(lastDate.year, lastDate.month, lastDate.day + 1)
                  .subtract(const Duration(seconds: 1));
          double maxX = adjustedLastDate.millisecondsSinceEpoch.toDouble();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.20,
                    child: DataChart(
                        chartData: chartData,
                        minY: 0,
                        maxY: maxY,
                        minX: minX,
                        maxX: maxX),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.50,
                    child: DataTableWidget(tableData: tableData),
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
