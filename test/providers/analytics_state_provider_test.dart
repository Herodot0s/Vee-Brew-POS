import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veebrew/providers/analytics_state_provider.dart';

void main() {
  test('AnalyticsStateNotifier initializes and updates state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var state = container.read(analyticsStateProvider);
    expect(state.range, TimeRange.day);

    container.read(analyticsStateProvider.notifier).setTimeRange(TimeRange.week);
    state = container.read(analyticsStateProvider);
    expect(state.range, TimeRange.week);

    final start = DateTime(2026, 6, 1);
    final end = DateTime(2026, 6, 2);
    container.read(analyticsStateProvider.notifier).setCustomRange(start, end);
    state = container.read(analyticsStateProvider);
    expect(state.range, TimeRange.custom);
    expect(state.startDate.year, 2026);
    expect(state.endDate.year, 2026);
  });
}
