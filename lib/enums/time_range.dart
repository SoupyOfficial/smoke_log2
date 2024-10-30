// enums/time_range.dart
enum TimeRange {
  week,
  month,
  threeMonths,
  sixMonths,
  year,
}

extension TimeRangeExtension on TimeRange {
  String get value {
    return toString().split('.').last;
  }
}
