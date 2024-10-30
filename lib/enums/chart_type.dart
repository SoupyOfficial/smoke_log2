// enums/chart_type.dart
enum ChartType {
  cumulative,
  thcConcentration,
  rolling24h,
  rolling30d,
  rolling90d,
}

extension ChartTypeExtension on ChartType {
  String get value {
    return toString().split('.').last;
  }

  String get displayName {
    switch (this) {
      case ChartType.cumulative:
        return 'Cumulative Usage';
      case ChartType.thcConcentration:
        return 'Decay Rate';
      case ChartType.rolling24h:
        return 'Rolling 24h Usage';
      case ChartType.rolling30d:
        return 'Rolling 30 Days Usage';
      case ChartType.rolling90d:
        return 'Rolling 90 Days Usage';
    }
  }
}
