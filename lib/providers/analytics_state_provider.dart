import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TimeRange { day, week, month, year, custom }

class AnalyticsFilterState {
  final TimeRange range;
  final DateTime startDate;
  final DateTime endDate;

  const AnalyticsFilterState({
    required this.range,
    required this.startDate,
    required this.endDate,
  });

  AnalyticsFilterState copyWith({
    TimeRange? range,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return AnalyticsFilterState(
      range: range ?? this.range,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class AnalyticsStateNotifier extends Notifier<AnalyticsFilterState> {
  @override
  AnalyticsFilterState build() {
    return _buildForRange(TimeRange.day);
  }

  void setTimeRange(TimeRange range) {
    if (range != TimeRange.custom) {
      state = _buildForRange(range);
    }
  }

  void setCustomRange(DateTime start, DateTime end) {
    state = AnalyticsFilterState(
      range: TimeRange.custom,
      startDate: DateTime(start.year, start.month, start.day, 0, 0, 0),
      endDate: DateTime(end.year, end.month, end.day, 23, 59, 59, 999),
    );
  }

  AnalyticsFilterState _buildForRange(TimeRange range) {
    final now = DateTime.now();
    final DateTime start;
    final DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    switch (range) {
      case TimeRange.day:
        start = DateTime(now.year, now.month, now.day, 0, 0, 0);
        break;
      case TimeRange.week:
        start = DateTime(now.year, now.month, now.day, 0, 0, 0).subtract(const Duration(days: 6));
        break;
      case TimeRange.month:
        start = DateTime(now.year, now.month, now.day, 0, 0, 0).subtract(const Duration(days: 29));
        break;
      case TimeRange.year:
        start = DateTime(now.year, now.month, now.day, 0, 0, 0).subtract(const Duration(days: 364));
        break;
      case TimeRange.custom:
        start = DateTime(now.year, now.month, now.day, 0, 0, 0);
        break;
    }

    return AnalyticsFilterState(
      range: range,
      startDate: start,
      endDate: end,
    );
  }
}

final analyticsStateProvider = NotifierProvider<AnalyticsStateNotifier, AnalyticsFilterState>(
  () => AnalyticsStateNotifier(),
);
