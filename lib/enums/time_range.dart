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

  double get inDays {
    switch (value) {
      case 'week':
        return 7;
      case 'month':
        return 30; // Assuming 30.4375 days in a month
      case 'threeMonths':
        return 9; // Assuming 91.25 days in three months
      case 'sixMonths':
        return 180; // Assuming 182.5 days in six months
      case 'year':
        return 365; // Assuming 365.25 days in a year
      default:
        return 0; // Return 0 for invalid values
    }
  }
}
