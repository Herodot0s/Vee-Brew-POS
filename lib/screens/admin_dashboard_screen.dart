import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../theme/binance_theme.dart';
import '../providers/admin_provider.dart';
import '../providers/data_providers.dart';
import '../providers/database_provider.dart';
import '../database/drift_database.dart';
import '../widgets/analytics/analytics_management_view.dart';
import '../widgets/admin/order_filter_sidebar.dart';
import '../widgets/admin/order_detail_view.dart';

class _OrderHistoryView extends ConsumerWidget {
  const _OrderHistoryView({super.key});

  void _showDeleteOrderConfirmation(BuildContext context, WidgetRef ref, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BinanceTheme.surfaceCardDark,
        title: Text(
          'Delete Order',
          style: BinanceTheme.titleStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete Order #${order.orderNumber}? This will permanently delete the order and all its items from the database.',
          style: BinanceTheme.titleStyle(color: BinanceTheme.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: BinanceTheme.titleStyle(color: BinanceTheme.muted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                final db = ref.read(databaseProvider);
                await db.transaction(() async {
                  await (db.delete(db.orderItems)..where((t) => t.orderId.equals(order.id))).go();
                  await (db.delete(db.orders)..where((t) => t.id.equals(order.id))).go();
                });
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Order #${order.orderNumber} deleted successfully.'),
                      backgroundColor: BinanceTheme.tradingUp,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting order: $e'),
                      backgroundColor: BinanceTheme.tradingDown,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(filteredOrdersStreamProvider);
    return Row(
      children: [
        const OrderFilterSidebar(),
        Expanded(
          child: ordersAsync.when(
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      order.isSynced
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
                      const SizedBox(width: BinanceTheme.spaceMd),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _showDeleteOrderConfirmation(context, ref, order),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(BinanceTheme.spaceMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (order.customerName != null && order.customerName!.trim().isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 16, color: BinanceTheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'Customer: ${order.customerName}',
                                  style: const TextStyle(
                                    color: BinanceTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Payment: ${order.paymentMethod}',
                                style: const TextStyle(color: BinanceTheme.muted),
                              ),
                              Text(
                                'Total: ₱${order.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: BinanceTheme.onDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (order.paymentMethod.toLowerCase() == 'cash' &&
                              order.amountReceived != null &&
                              order.changeAmount != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Amount Received: ₱${order.amountReceived!.toStringAsFixed(2)}',
                                  style: const TextStyle(color: BinanceTheme.muted),
                                ),
                                Text(
                                  'Change: ₱${order.changeAmount!.toStringAsFixed(2)}',
                                  style: const TextStyle(color: BinanceTheme.muted),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          OrderDetailView(orderId: order.id),
                        ],
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
          ),
        ),
      ],
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
                const _ProductManagementView(),
                const _ModifierManagementView(),
                const AnalyticsManagementView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModifierManagementView extends ConsumerWidget {
  const _ModifierManagementView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modifiersAsync = ref.watch(adminFilteredModifiersProvider);
    final allModifiersAsync = ref.watch(modifiersStreamProvider);
    final selectedGroupId = ref.watch(adminSelectedModifierGroupProvider);

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(BinanceTheme.spaceMd),
          child: TextField(
            style: const TextStyle(color: BinanceTheme.onDark),
            decoration: InputDecoration(
              hintText: 'Search modifiers...',
              hintStyle: const TextStyle(color: BinanceTheme.muted),
              prefixIcon: const Icon(Icons.search, color: BinanceTheme.muted),
              filled: true,
              fillColor: BinanceTheme.surfaceElevatedDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: BinanceTheme.primary),
              ),
            ),
            onChanged: (val) =>
                ref.read(adminModifierSearchQueryProvider.notifier).value = val,
          ),
        ),

        // Group Toggles
        allModifiersAsync.when(
          data: (all) {
            final groups = all.map((m) => m.groupName).toSet().toList()..sort();
            return SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: BinanceTheme.spaceMd,
                ),
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: selectedGroupId == null,
                    onTap: () =>
                        ref
                                .read(
                                  adminSelectedModifierGroupProvider.notifier,
                                )
                                .value =
                            null,
                  ),
                  ...groups.map(
                    (g) => _FilterChip(
                      label: g,
                      isSelected: selectedGroupId == g,
                      onTap: () =>
                          ref
                                  .read(
                                    adminSelectedModifierGroupProvider.notifier,
                                  )
                                  .value =
                              g,
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox(height: 40),
          error: (_, __) => const SizedBox(height: 40),
        ),

        const SizedBox(height: 8),

        // Modifier List
        Expanded(
          child: modifiersAsync.when(
            data: (modifiers) => ListView(
              children: [
                ...modifiers.map((m) {
                  final productLabel = m.productCount > 1
                      ? 'for ${m.productCount} products'
                      : m.product != null
                      ? 'for ${m.product!.name}'
                      : null;

                  return ListTile(
                    title: Text(
                      m.modifier.name,
                      style: const TextStyle(color: BinanceTheme.onDark),
                    ),
                    subtitle: Text(
                      '${m.modifier.groupName} | ₱${m.modifier.priceDelta.toStringAsFixed(2)}${productLabel != null ? ' | $productLabel' : ''}',
                      style: const TextStyle(color: BinanceTheme.muted),
                    ),
                    trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: BinanceTheme.primary,
                                ),
                                onPressed: () => _showModifierDialog(
                                  context,
                                  ref,
                                  modifier: m.modifier,
                                  isShared: m.productCount > 1,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _showDeleteModifierConfirmation(
                                      context,
                                      ref,
                                      m.modifier,
                                      isShared: m.productCount > 1,
                                      productCount: m.productCount,
                                    ),
                              ),
                            ],
                          ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.all(BinanceTheme.spaceMd),
                  child: ElevatedButton(
                    onPressed: () => _showModifierDialog(context, ref),
                    child: const Text('Add Modifier'),
                  ),
                ),
              ],
            ),
            error: (_, __) => const Center(
              child: Text(
                'Error loading modifiers',
                style: TextStyle(color: Colors.red),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }

  void _showModifierDialog(
    BuildContext context,
    WidgetRef ref, {
    Modifier? modifier,
    bool isShared = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => _ModifierEditDialog(modifier: modifier),
    );
  }

  void _showDeleteModifierConfirmation(
    BuildContext context,
    WidgetRef ref,
    Modifier modifier, {
    bool isShared = false,
    int productCount = 1,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BinanceTheme.surfaceCardDark,
        title: const Text(
          'Delete Modifier',
          style: TextStyle(color: BinanceTheme.onDark),
        ),
        content: Text(
          isShared
              ? 'Delete ${modifier.name} from $productCount products?'
              : 'Delete ${modifier.name}?',
          style: const TextStyle(color: BinanceTheme.onDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final db = ref.read(databaseProvider);
              if (isShared) {
                await (db.delete(db.modifiers)
                      ..where((t) => t.id.equals(modifier.id)))
                    .go();
              } else {
                await (db.delete(db.modifiers)
                      ..where(
                        (t) =>
                            t.id.equals(modifier.id) &
                            t.productId.equals(modifier.productId),
                      ))
                    .go();
              }
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ModifierEditDialog extends ConsumerStatefulWidget {
  final Modifier? modifier;

  const _ModifierEditDialog({super.key, this.modifier});

  @override
  ConsumerState<_ModifierEditDialog> createState() => _ModifierEditDialogState();
}

class _ModifierEditDialogState extends ConsumerState<_ModifierEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _groupController;
  final Set<String> _selectedProductIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.modifier?.name);
    _priceController = TextEditingController(text: widget.modifier?.priceDelta.toString() ?? '');
    _groupController = TextEditingController(text: widget.modifier?.groupName);
    _loadInitialAssignments();
  }

  Future<void> _loadInitialAssignments() async {
    if (widget.modifier != null) {
      final db = ref.read(databaseProvider);
      final existing = await (db.select(db.modifiers)
            ..where((t) => t.id.equals(widget.modifier!.id)))
          .get();
      setState(() {
        _selectedProductIds.addAll(existing.map((m) => m.productId));
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AlertDialog(
        backgroundColor: BinanceTheme.surfaceCardDark,
        content: Center(child: CircularProgressIndicator()),
      );
    }

    final productsAsync = ref.watch(allProductsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return productsAsync.when(
      data: (products) {
        // Group products by category
        final Map<String, List<Product>> categoryToProducts = {};
        for (final prod in products) {
          categoryToProducts.putIfAbsent(prod.categoryId, () => []).add(prod);
        }

        final canSave = _nameController.text.isNotEmpty &&
            _priceController.text.isNotEmpty &&
            _groupController.text.isNotEmpty &&
            _selectedProductIds.isNotEmpty;

        return AlertDialog(
          backgroundColor: BinanceTheme.surfaceCardDark,
          title: Text(
            widget.modifier == null ? 'Add Modifier' : 'Edit Modifier',
            style: const TextStyle(color: BinanceTheme.onDark),
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: BinanceTheme.onDark),
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: BinanceTheme.muted),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  TextField(
                    controller: _priceController,
                    style: const TextStyle(color: BinanceTheme.onDark),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Price Delta',
                      labelStyle: TextStyle(color: BinanceTheme.muted),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  TextField(
                    controller: _groupController,
                    style: const TextStyle(color: BinanceTheme.onDark),
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                      hintText: 'e.g., Size, Syrup',
                      hintStyle: TextStyle(color: BinanceTheme.muted),
                      labelStyle: TextStyle(color: BinanceTheme.muted),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Applies to Products',
                    style: TextStyle(
                      color: BinanceTheme.onDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      border: Border.all(color: BinanceTheme.surfaceElevatedDark),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: categoriesAsync.when(
                      data: (categories) {
                        return ListView(
                          shrinkWrap: true,
                          children: categories.map((cat) {
                            final catProducts = categoryToProducts[cat.id] ?? [];
                            if (catProducts.isEmpty) return const SizedBox.shrink();

                            final catProductIds = catProducts.map((p) => p.id).toSet();
                            final isAllSelected = catProductIds.every((id) => _selectedProductIds.contains(id));

                            return ExpansionTile(
                              title: Text(cat.name, style: const TextStyle(color: BinanceTheme.onDark)),
                              children: [
                                CheckboxListTile(
                                  title: Text('Select All ${cat.name}', style: const TextStyle(color: BinanceTheme.muted, fontStyle: FontStyle.italic)),
                                  value: isAllSelected,
                                  activeColor: BinanceTheme.primary,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedProductIds.addAll(catProductIds);
                                      } else {
                                        _selectedProductIds.removeAll(catProductIds);
                                      }
                                    });
                                  },
                                ),
                                ...catProducts.map((prod) {
                                  final isSelected = _selectedProductIds.contains(prod.id);
                                  return CheckboxListTile(
                                    title: Text(prod.name, style: const TextStyle(color: BinanceTheme.onDark)),
                                    value: isSelected,
                                    activeColor: BinanceTheme.primary,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedProductIds.add(prod.id);
                                        } else {
                                          _selectedProductIds.remove(prod.id);
                                        }
                                      });
                                    },
                                  );
                                }),
                              ],
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const Text('Error loading categories', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: !canSave
                  ? null
                  : () async {
                      final db = ref.read(databaseProvider);
                      final price = double.tryParse(_priceController.text) ?? 0.0;
                      final name = _nameController.text;
                      final group = _groupController.text;

                      if (widget.modifier == null) {
                        final newId = DateTime.now().millisecondsSinceEpoch.toString();
                        await db.transaction(() async {
                          for (final prodId in _selectedProductIds) {
                            await db.into(db.modifiers).insert(
                              ModifiersCompanion.insert(
                                id: newId,
                                productId: prodId,
                                name: name,
                                priceDelta: price,
                                groupName: group,
                              ),
                            );
                          }
                        });
                      } else {
                        await db.transaction(() async {
                          final existing = await (db.select(db.modifiers)
                                ..where((t) => t.id.equals(widget.modifier!.id)))
                              .get();
                          final existingProdIds = existing.map((m) => m.productId).toSet();

                          final toAdd = _selectedProductIds.difference(existingProdIds);
                          for (final prodId in toAdd) {
                            await db.into(db.modifiers).insert(
                              ModifiersCompanion.insert(
                                id: widget.modifier!.id,
                                productId: prodId,
                                name: name,
                                priceDelta: price,
                                groupName: group,
                              ),
                            );
                          }

                          final toDelete = existingProdIds.difference(_selectedProductIds);
                          if (toDelete.isNotEmpty) {
                            await (db.delete(db.modifiers)
                                  ..where((t) => t.id.equals(widget.modifier!.id) & t.productId.isIn(toDelete)))
                                .go();
                          }

                          final remaining = _selectedProductIds.intersection(existingProdIds);
                          if (remaining.isNotEmpty) {
                            await (db.update(db.modifiers)
                                  ..where((t) => t.id.equals(widget.modifier!.id) & t.productId.isIn(remaining)))
                                .write(
                                  ModifiersCompanion(
                                    name: Value(name),
                                    priceDelta: Value(price),
                                    groupName: Value(group),
                                  ),
                                );
                          }
                        });
                      }
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
              child: const Text('Save'),
            ),
          ],
        );
      },
      error: (_, __) => const AlertDialog(content: Text('Error loading products')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ProductManagementView extends ConsumerWidget {
  const _ProductManagementView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(adminFilteredProductsProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final selectedCategoryId = ref.watch(adminSelectedCategoryProvider);

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(BinanceTheme.spaceMd),
          child: TextField(
            style: const TextStyle(color: BinanceTheme.onDark),
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: const TextStyle(color: BinanceTheme.muted),
              prefixIcon: const Icon(Icons.search, color: BinanceTheme.muted),
              filled: true,
              fillColor: BinanceTheme.surfaceElevatedDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: BinanceTheme.primary),
              ),
            ),
            onChanged: (val) =>
                ref.read(adminSearchQueryProvider.notifier).value = val,
          ),
        ),

        // Category Toggles
        categoriesAsync.when(
          data: (categories) => SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: BinanceTheme.spaceMd,
              ),
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: selectedCategoryId == null,
                  onTap: () =>
                      ref.read(adminSelectedCategoryProvider.notifier).value =
                          null,
                ),
                ...categories.map(
                  (c) => _FilterChip(
                    label: c.name,
                    isSelected: selectedCategoryId == c.id,
                    onTap: () =>
                        ref.read(adminSelectedCategoryProvider.notifier).value =
                            c.id,
                  ),
                ),
              ],
            ),
          ),
          loading: () => const SizedBox(height: 40),
          error: (_, __) => const SizedBox(height: 40),
        ),

        const SizedBox(height: 8),

        // Product List
        Expanded(
          child: productsAsync.when(
            data: (products) => ListView(
              children: [
                ...products.map((p) {
                  final categoryName = categoriesAsync.maybeWhen(
                    data: (cats) {
                      try {
                        return cats
                            .firstWhere((c) => c.id == p.categoryId)
                            .name;
                      } catch (_) {
                        return 'Unknown';
                      }
                    },
                    orElse: () => 'Loading...',
                  );
                  return ListTile(
                    title: Text(
                      p.name,
                      style: const TextStyle(color: BinanceTheme.onDark),
                    ),
                    subtitle: Text(
                      '$categoryName | ₱${p.basePrice.toStringAsFixed(2)}',
                      style: const TextStyle(color: BinanceTheme.muted),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: BinanceTheme.primary,
                          ),
                          onPressed: () =>
                              _showProductDialog(context, ref, product: p),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _showDeleteConfirmation(context, ref, p),
                        ),
                      ],
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.all(BinanceTheme.spaceMd),
                  child: ElevatedButton(
                    onPressed: () => _showProductDialog(context, ref),
                    child: const Text('Add Product'),
                  ),
                ),
              ],
            ),
            error: (_, __) => const Center(
              child: Text(
                'Error loading products',
                style: TextStyle(color: Colors.red),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }

  void _showProductDialog(
    BuildContext context,
    WidgetRef ref, {
    Product? product,
  }) {
    final nameController = TextEditingController(text: product?.name);
    final priceController = TextEditingController(
      text: product?.basePrice.toString(),
    );
    final categoriesAsync = ref.read(categoriesStreamProvider);
    String? selectedCategoryId = product?.categoryId;

    showDialog(
      context: context,
      builder: (context) {
        return categoriesAsync.when(
          data: (categories) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              backgroundColor: BinanceTheme.surfaceCardDark,
              title: Text(
                product == null ? 'Add Product' : 'Edit Product',
                style: const TextStyle(color: BinanceTheme.onDark),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: BinanceTheme.onDark),
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        labelStyle: TextStyle(color: BinanceTheme.muted),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: BinanceTheme.muted),
                        ),
                      ),
                    ),
                    TextField(
                      controller: priceController,
                      style: const TextStyle(color: BinanceTheme.onDark),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Base Price',
                        labelStyle: TextStyle(color: BinanceTheme.muted),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: BinanceTheme.muted),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      dropdownColor: BinanceTheme.surfaceCardDark,
                      value: selectedCategoryId,
                      style: const TextStyle(color: BinanceTheme.onDark),
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(color: BinanceTheme.muted),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: BinanceTheme.muted),
                        ),
                      ),
                      items: categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => selectedCategoryId = val),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        priceController.text.isEmpty ||
                        selectedCategoryId == null)
                      return;

                    final db = ref.read(databaseProvider);
                    final price = double.tryParse(priceController.text) ?? 0.0;

                    if (product == null) {
                      await db
                          .into(db.products)
                          .insert(
                            ProductsCompanion.insert(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              name: nameController.text,
                              basePrice: price,
                              categoryId: selectedCategoryId!,
                            ),
                          );
                    } else {
                      await (db.update(
                        db.products,
                      )..where((t) => t.id.equals(product.id))).write(
                        ProductsCompanion(
                          name: Value(nameController.text),
                          basePrice: Value(price),
                          categoryId: Value(selectedCategoryId!),
                        ),
                      );
                    }
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
          error: (_, __) =>
              const AlertDialog(content: Text('Error loading categories')),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BinanceTheme.surfaceCardDark,
        title: const Text(
          'Delete Product',
          style: TextStyle(color: BinanceTheme.onDark),
        ),
        content: Text(
          'Are you sure you want to delete ${product.name}?',
          style: const TextStyle(color: BinanceTheme.onDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final db = ref.read(databaseProvider);
              await (db.delete(
                db.products,
              )..where((t) => t.id.equals(product.id))).go();
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? BinanceTheme.primary
                : BinanceTheme.surfaceElevatedDark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : BinanceTheme.onDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem('Revenue', '₱${totalRevenue.toStringAsFixed(2)}'),
                const SizedBox(width: 16),
                _statItem('Sync Rate', '$syncRate%'),
                const SizedBox(width: 16),
                _statItem('Avg Latency', '${avgLatency}ms'),
                const SizedBox(width: 16),
                _statItem('Transactions', '${orders.length}'),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    final db = ref.read(databaseProvider);
                    await db.transaction(() async {
                      await db.delete(db.orderItems).go();
                      await db.delete(db.orders).go();
                      await db.delete(db.modifiers).go();
                      await db.delete(db.products).go();
                      await db.delete(db.categories).go();
                    });
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Database Wiped Fully')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    'WIPE DATABASE',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
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
                const SizedBox(width: 8),
              ],
            ),
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
        padding: const EdgeInsets.all(BinanceTheme.spaceMd),
        children: [
          ...categories.map(
            (c) => Card(
              color: BinanceTheme.surfaceCardDark,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: BinanceTheme.surfaceElevatedDark),
              ),
              child: ListTile(
                title: Text(
                  c.name,
                  style: const TextStyle(
                    color: BinanceTheme.onDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteCategoryConfirmation(context, ref, c),
                ),
              ),
            ),
          ),
          const SizedBox(height: BinanceTheme.spaceMd),
          ElevatedButton.icon(
            onPressed: () => _showAddCategoryDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add Category'),
            style: ElevatedButton.styleFrom(
              backgroundColor: BinanceTheme.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
      error: (_, __) => const Center(
        child: Text(
          'Error loading categories',
          style: TextStyle(color: Colors.red),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showDeleteCategoryConfirmation(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BinanceTheme.surfaceCardDark,
        title: const Text(
          'Delete Category',
          style: TextStyle(color: BinanceTheme.onDark),
        ),
        content: Text(
          'Are you sure you want to delete ${category.name}?\nAll products in this category will lose their group association.',
          style: const TextStyle(color: BinanceTheme.body),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: BinanceTheme.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final db = ref.read(databaseProvider);
              await (db.delete(
                db.categories,
              )..where((t) => t.id.equals(category.id))).go();
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BinanceTheme.surfaceCardDark,
        title: const Text(
          'Add Category',
          style: TextStyle(color: BinanceTheme.onDark),
        ),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: BinanceTheme.onDark),
          decoration: const InputDecoration(
            labelText: 'Category Name',
            labelStyle: TextStyle(color: BinanceTheme.muted),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: BinanceTheme.surfaceElevatedDark),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: BinanceTheme.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: BinanceTheme.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: BinanceTheme.primary,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final db = ref.read(databaseProvider);
              await db
                  .into(db.categories)
                  .insert(
                    CategoriesCompanion.insert(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text.trim(),
                      sortOrder: 0,
                    ),
                  );
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
