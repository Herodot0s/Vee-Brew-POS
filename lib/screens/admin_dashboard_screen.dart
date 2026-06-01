import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../theme/binance_theme.dart';
import '../providers/admin_provider.dart';
import '../providers/data_providers.dart';
import '../providers/database_provider.dart';
import '../database/drift_database.dart';
import '../widgets/analytics/analytics_management_view.dart';

class _OrderHistoryView extends ConsumerWidget {
  const _OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersStreamProvider);
    return ordersAsync.when(
      data: (orders) => ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return ExpansionTile(
            title: Text(
              'Order #${order.orderNumber}',
              style: const TextStyle(color: BinanceTheme.onDark),
            ),
            subtitle: Text('Status: ${order.isSynced ? 'Synced' : 'Pending'}'),
            trailing: order.isSynced
                ? const Icon(Icons.check, color: Colors.green)
                : ElevatedButton(
                    onPressed: () async {
                      final db = ref.read(databaseProvider);
                      await Future.delayed(const Duration(milliseconds: 1200));
                      await (db.update(db.orders)
                            ..where((t) => t.id.equals(order.id)))
                          .write(OrdersCompanion(isSynced: Value(true)));
                    },
                    child: const Text('Sync'),
                  ),
            children: [
              Padding(
                padding: const EdgeInsets.all(BinanceTheme.spaceMd),
                child: Text(
                  'Total: ₱${order.totalAmount}',
                  style: const TextStyle(color: BinanceTheme.onDark),
                ),
              ),
            ],
          );
        },
      ),
      error: (_, __) => const Center(
        child: Text(
          'Error loading orders',
          style: TextStyle(color: Colors.red),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          const _PerformanceStatsBar(),
          Container(
            color: BinanceTheme.surfaceElevatedDark,
            child: const TabBar(
              labelColor: BinanceTheme.onDark,
              unselectedLabelColor: BinanceTheme.muted,
              indicatorColor: BinanceTheme.primary,
              isScrollable: true,
              tabs: [
                Tab(text: 'Orders'),
                Tab(text: 'Categories'),
                Tab(text: 'Products'),
                Tab(text: 'Modifiers'),
                Tab(text: 'Analytics'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                const _OrderHistoryView(),
                const _CategoryManagementView(),
                const Center(
                  child: Text(
                    'Products Placeholder',
                    style: TextStyle(color: BinanceTheme.onDark),
                  ),
                ),
                const Center(
                  child: Text(
                    'Modifiers Placeholder',
                    style: TextStyle(color: BinanceTheme.onDark),
                  ),
                ),
                const AnalyticsManagementView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceStatsBar extends ConsumerWidget {
  const _PerformanceStatsBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersStreamProvider);
    final latencies = ref.watch(checkoutDurationProvider);

    return ordersAsync.when(
      data: (orders) {
        final totalRevenue = orders.fold(0.0, (sum, o) => sum + o.totalAmount);
        final syncedCount = orders.where((o) => o.isSynced).length;
        final syncRate = orders.isNotEmpty
            ? (syncedCount / orders.length * 100).toInt()
            : 0;
        final avgLatency = latencies.isNotEmpty
            ? (latencies.reduce((a, b) => a + b) / latencies.length).toInt()
            : 0;

        return Container(
          padding: const EdgeInsets.all(BinanceTheme.spaceMd),
          decoration: const BoxDecoration(color: BinanceTheme.surfaceCardDark),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('Revenue', '₱${totalRevenue.toStringAsFixed(2)}'),
              _statItem('Sync Rate', '$syncRate%'),
              _statItem('Avg Latency', '${avgLatency}ms'),
              _statItem('Transactions', '${orders.length}'),
              ElevatedButton(
                onPressed: () async {
                  final db = ref.read(databaseProvider);
                  final pending = orders.where((o) => !o.isSynced);
                  for (final order in pending) {
                    await Future.delayed(const Duration(milliseconds: 1200));
                    await (db.update(db.orders)
                          ..where((t) => t.id.equals(order.id)))
                        .write(OrdersCompanion(isSynced: Value(true)));
                  }
                },
                child: const Text('Sync All Pending'),
              ),
            ],
          ),
        );
      },
      error: (_, __) => const SizedBox(),
      loading: () => const LinearProgressIndicator(),
    );
  }

  Widget _statItem(String label, String value) => Column(
    children: [
      Text(
        label,
        style: const TextStyle(color: BinanceTheme.muted, fontSize: 12),
      ),
      Text(
        value,
        style: const TextStyle(
          color: BinanceTheme.onDark,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

class _CategoryManagementView extends ConsumerWidget {
  const _CategoryManagementView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    return categoriesAsync.when(
      data: (categories) => ListView(
        children: [
          ...categories.map(
            (c) => ListTile(
              title: Text(
                c.name,
                style: const TextStyle(color: BinanceTheme.onDark),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final db = ref.read(databaseProvider);
                  await (db.delete(
                    db.categories,
                  )..where((t) => t.id.equals(c.id))).go();
                },
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _showAddCategoryDialog(context, ref),
            child: const Text('Add Category'),
          ),
        ],
      ),
      error: (_, __) => const SizedBox(),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(controller: nameController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final db = ref.read(databaseProvider);
              await db
                  .into(db.categories)
                  .insert(
                    CategoriesCompanion.insert(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      sortOrder: 0,
                    ),
                  );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
