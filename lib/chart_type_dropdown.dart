// chart_type_dropdown.dart
import 'package:flutter/material.dart';
import 'utils/constants.dart';
import 'enums/chart_type.dart';

class ChartTypeDropdown extends StatelessWidget {
  final ChartType selectedChartType;
  final ValueChanged<ChartType?> onChanged;

  const ChartTypeDropdown({
    required this.selectedChartType,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<ChartType>(
      value: selectedChartType,
      onChanged: onChanged,
      items: ChartType.values.map((type) {
        return DropdownMenuItem<ChartType>(
          value: type,
          child: Text(type.displayName),
        );
      }).toList(),
    );
  }

  String _getUsageText(String value) {
    return usageTextMap[value] ?? 'Unknown Usage';
  }
}
