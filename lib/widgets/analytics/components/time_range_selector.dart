import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/binance_theme.dart';
import '../../../providers/analytics_state_provider.dart';

class TimeRangeSelector extends ConsumerWidget {
  const TimeRangeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(analyticsStateProvider);
    return Row(
      children: TimeRange.values.map((range) {
        final isSelected = range == currentFilter.range;
        return Padding(
          padding: const EdgeInsets.only(right: BinanceTheme.spaceXs),
          child: ChoiceChip(
            label: Text(range.name.capitalize()),
            selected: isSelected,
            onSelected: (_) async {
              if (range == TimeRange.custom) {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDateRange: DateTimeRange(
                    start: currentFilter.startDate,
                    end: currentFilter.endDate,
                  ),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: BinanceTheme.primary,
                          onPrimary: BinanceTheme.onPrimary,
                          surface: BinanceTheme.surfaceCardDark,
                          onSurface: BinanceTheme.onDark,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  ref.read(analyticsStateProvider.notifier).setCustomRange(picked.start, picked.end);
                }
              } else {
                ref.read(analyticsStateProvider.notifier).setTimeRange(range);
              }
            },
          ),
        );
      }).toList(),
    );
  }
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}
