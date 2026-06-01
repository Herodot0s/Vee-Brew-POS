import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TimeRange { day, week, month, year }

class AnalyticsStateNotifier extends Notifier<TimeRange> {
  @override
  TimeRange build() => TimeRange.day;

  void setTimeRange(TimeRange range) {
    state = range;
  }
}

final analyticsStateProvider = NotifierProvider<AnalyticsStateNotifier, TimeRange>(
  () => AnalyticsStateNotifier(),
);
