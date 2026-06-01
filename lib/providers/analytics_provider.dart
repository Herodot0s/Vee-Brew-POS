import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'data_providers.dart';

part 'analytics_provider.g.dart';

@riverpod
class AnalyticsState extends _$AnalyticsState {
  @override
  TimeRange build() => TimeRange.day;

  void setTimeRange(TimeRange range) {
    state = range;
  }
}
