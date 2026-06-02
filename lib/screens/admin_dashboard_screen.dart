import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
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
    final nameController = TextEditingController(text: modifier?.name);
    final priceController = TextEditingController(
      text: modifier?.priceDelta.toString(),
    );
    final groupController = TextEditingController(text: modifier?.groupName);
    String? selectedProductId = modifier?.productId;

    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final productsAsync = ref.watch(allProductsStreamProvider);
          return productsAsync.when(
            data: (products) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                backgroundColor: BinanceTheme.surfaceCardDark,
                title: Text(
                  modifier == null
                      ? 'Add Modifier'
                      : (isShared ? 'Edit Shared Modifier' : 'Edit Modifier'),
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
                          labelText: 'Name',
                          labelStyle: TextStyle(color: BinanceTheme.muted),
                        ),
                      ),
                      TextField(
                        controller: priceController,
                        style: const TextStyle(color: BinanceTheme.onDark),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Price Delta',
                          labelStyle: TextStyle(color: BinanceTheme.muted),
                        ),
                      ),
                      TextField(
                        controller: groupController,
                        style: const TextStyle(color: BinanceTheme.onDark),
                        decoration: const InputDecoration(
                          labelText: 'Group Name',
                          hintText: 'e.g., Size, Syrup',
                          hintStyle: TextStyle(color: BinanceTheme.muted),
                          labelStyle: TextStyle(color: BinanceTheme.muted),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isShared)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Applied to multiple products',
                            style: TextStyle(
                              color: BinanceTheme.muted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else
                        DropdownButtonFormField<String>(
                          dropdownColor: BinanceTheme.surfaceCardDark,
                          value: selectedProductId,
                          style: const TextStyle(color: BinanceTheme.onDark),
                          decoration: const InputDecoration(
                            labelText: 'Target Product',
                            labelStyle: TextStyle(color: BinanceTheme.muted),
                          ),
                          items: products
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p.id,
                                  child: Text(p.name),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => selectedProductId = val),
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
                          groupController.text.isEmpty ||
                          (!isShared && selectedProductId == null))
                        return;
                      final db = ref.read(databaseProvider);
                      final price =
                          double.tryParse(priceController.text) ?? 0.0;

                      if (modifier == null) {
                        await db
                            .into(db.modifiers)
                            .insert(
                              ModifiersCompanion.insert(
                                id: DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                productId: selectedProductId!,
                                name: nameController.text,
                                priceDelta: price,
                                groupName: groupController.text,
                              ),
                            );
                      } else {
                        if (isShared) {
                          await (db.update(db.modifiers)
                                ..where((t) => t.id.equals(modifier.id)))
                              .write(
                                ModifiersCompanion(
                                  name: Value(nameController.text),
                                  priceDelta: Value(price),
                                  groupName: Value(groupController.text),
                                ),
                              );
                        } else {
                          await (db.update(db.modifiers)
                                ..where(
                                  (t) =>
                                      t.id.equals(modifier.id) &
                                      t.productId.equals(modifier.productId),
                                ))
                              .write(
                                ModifiersCompanion(
                                  productId: Value(selectedProductId!),
                                  name: Value(nameController.text),
                                  priceDelta: Value(price),
                                  groupName: Value(groupController.text),
                                ),
                              );
                        }
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
            error: (_, __) =>
                const AlertDialog(content: Text('Error loading products')),
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
      ),
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
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Database Wiped Fully')),
                      );
                    }
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
              if (context.mounted) Navigator.pop(context);
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
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
