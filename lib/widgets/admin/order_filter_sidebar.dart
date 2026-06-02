import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../theme/binance_theme.dart';

class OrderFilterSidebar extends ConsumerWidget {
  const OrderFilterSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(adminOrderFilterProvider);
    final isCustomSelected = activeFilter.label == 'Custom';

    return Container(
      width: 200,
      color: BinanceTheme.surfaceElevatedDark,
      child: Column(
        children: [
          _FilterButton(
            label: 'Today',
            range: AdminOrderFilterNotifier.getTodayRange(),
          ),
          _FilterButton(
            label: 'This Week',
            range: AdminOrderFilterNotifier.getWeekRange(),
          ),
          _FilterButton(
            label: 'This Month',
            range: AdminOrderFilterNotifier.getMonthRange(),
          ),
          _FilterButton(
            label: 'This Year',
            range: AdminOrderFilterNotifier.getYearRange(),
          ),
          const Divider(color: BinanceTheme.surfaceCardDark),
          ListTile(
            title: Text(
              'Custom Range',
              style: BinanceTheme.titleStyle(
                color: isCustomSelected ? BinanceTheme.primary : BinanceTheme.onDark,
              ),
            ),
            onTap: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2024),
                lastDate: DateTime.now().add(const Duration(days: 1)),
              );
              if (range != null) {
                ref.read(adminOrderFilterProvider.notifier).state = AdminOrderFilter(
                  start: range.start,
                  end: range.end.add(const Duration(days: 1)),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends ConsumerWidget {
  final String label;
  final AdminOrderFilter range;

  const _FilterButton({required this.label, required this.range});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(adminOrderFilterProvider).label == label;
    return ListTile(
      title: Text(
        label,
        style: BinanceTheme.titleStyle(
          color: isSelected ? BinanceTheme.primary : BinanceTheme.onDark,
        ),
      ),
      onTap: () => ref.read(adminOrderFilterProvider.notifier).state = range,
    );
  }
}
