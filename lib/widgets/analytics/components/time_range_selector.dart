import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/binance_theme.dart';
import '../../../providers/analytics_state_provider.dart';

class TimeRangeSelector extends ConsumerWidget {
  const TimeRangeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRange = ref.watch(analyticsStateProvider);
    return Row(
      children: TimeRange.values.map((range) {
        final isSelected = range == currentRange;
        return Padding(
          padding: const EdgeInsets.only(right: BinanceTheme.spaceXs),
          child: ChoiceChip(
            label: Text(range.name.capitalize()),
            selected: isSelected,
            onSelected: (_) =>
                ref.read(analyticsStateProvider.notifier).setTimeRange(range),
          ),
        );
      }).toList(),
    );
  }
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}
