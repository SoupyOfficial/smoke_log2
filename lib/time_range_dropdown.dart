// time_range_dropdown.dart
import 'package:flutter/material.dart';
import 'enums/time_range.dart';

class TimeRangeDropdown extends StatelessWidget {
  final TimeRange selectedRange;
  final ValueChanged<TimeRange?> onChanged;

  const TimeRangeDropdown({
    required this.selectedRange,
    required this.onChanged,
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return DropdownButton<TimeRange>(
      value: selectedRange,
      onChanged: onChanged,
      items: TimeRange.values.map((range) {
        return DropdownMenuItem<TimeRange>(
          value: range,
          child: Text(range.value),
        );
      }).toList(),
    );
  }
}
