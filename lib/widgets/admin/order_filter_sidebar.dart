import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../theme/binance_theme.dart';

class OrderFilterSidebar extends ConsumerWidget {
  const OrderFilterSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 200,
      color: BinanceTheme.surfaceElevatedDark,
      child: Column(
        children: [
          _filterButton(context, ref, 'Today', _getTodayRange()),
          _filterButton(context, ref, 'This Week', _getWeekRange()),
          _filterButton(context, ref, 'This Month', _getMonthRange()),
          _filterButton(context, ref, 'This Year', _getYearRange()),
          const Divider(color: BinanceTheme.surfaceCardDark),
          ListTile(
            title: const Text('Custom Range', style: TextStyle(color: BinanceTheme.primary)),
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

  Widget _filterButton(BuildContext context, WidgetRef ref, String label, AdminOrderFilter range) {
    final isSelected = ref.watch(adminOrderFilterProvider).label == label;
    return ListTile(
      title: Text(label, style: TextStyle(color: isSelected ? BinanceTheme.primary : BinanceTheme.onDark)),
      onTap: () => ref.read(adminOrderFilterProvider.notifier).state = range,
    );
  }

  AdminOrderFilter _getTodayRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return AdminOrderFilter(start: start, end: start.add(const Duration(days: 1)), label: 'Today');
  }

  AdminOrderFilter _getWeekRange() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final startDay = DateTime(start.year, start.month, start.day);
    return AdminOrderFilter(start: startDay, end: startDay.add(const Duration(days: 7)), label: 'This Week');
  }

  AdminOrderFilter _getMonthRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    return AdminOrderFilter(start: start, end: end, label: 'This Month');
  }

  AdminOrderFilter _getYearRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year + 1, 1, 1);
    return AdminOrderFilter(start: start, end: end, label: 'This Year');
  }
}
