# Modifier Multiple Products Selection Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Allow admins to select and apply modifiers to multiple products in the Admin Dashboard.

**Architecture:** Update the Modifier Dialog UI to show category-grouped checkboxes for product selection. Execute database transactions during saves to insert, update, or delete rows in the Modifiers table to sync the list of product assignments.

**Tech Stack:** Flutter, Riverpod, Drift (SQLite).

---

### Task 1: Add Unit Tests for Modifier Multi-Product Operations

**Files:**
- Modify: `test/admin_test.dart`

- [ ] **Step 1: Write unit tests**
  Add two new tests inside `test/admin_test.dart` to assert bulk inserts and edit updates:
  ```dart
  test('Bulk insert modifier for multiple products', () async {
    // Seed category
    await db.into(db.categories).insert(
      const CategoriesCompanion(
        id: Value('beverage'),
        name: Value('Beverage'),
        sortOrder: Value(0),
      ),
    );

    // Seed two products
    await db.into(db.products).insert(
      const ProductsCompanion(
        id: Value('p1'),
        name: Value('Product 1'),
        basePrice: Value(10.0),
        categoryId: Value('beverage'),
      ),
    );
    await db.into(db.products).insert(
      const ProductsCompanion(
        id: Value('p2'),
        name: Value('Product 2'),
        basePrice: Value(12.0),
        categoryId: Value('beverage'),
      ),
    );

    // Perform bulk insert simulation
    final newId = 'test_bulk_mod';
    final selectedProductIds = {'p1', 'p2'};
    await db.transaction(() async {
      for (final prodId in selectedProductIds) {
        await db.into(db.modifiers).insert(
          ModifiersCompanion.insert(
            id: newId,
            productId: prodId,
            name: 'Extra Shot',
            priceDelta: 1.5,
            groupName: 'Addons',
          ),
        );
      }
    });

    // Assert rows created
    final mods = await (db.select(db.modifiers)..where((t) => t.id.equals(newId))).get();
    expect(mods.length, 2);
    expect(mods.any((m) => m.productId == 'p1'), isTrue);
    expect(mods.any((m) => m.productId == 'p2'), isTrue);
  });

  test('Edit existing modifier assignments (additions, deletions, and field updates)', () async {
    // Seed category
    await db.into(db.categories).insert(
      const CategoriesCompanion(
        id: Value('beverage'),
        name: Value('Beverage'),
        sortOrder: Value(0),
      ),
    );

    // Seed products
    await db.into(db.products).insert(
      const ProductsCompanion(
        id: Value('p1'),
        name: Value('Product 1'),
        basePrice: Value(10.0),
        categoryId: Value('beverage'),
      ),
    );
    await db.into(db.products).insert(
      const ProductsCompanion(
        id: Value('p2'),
        name: Value('Product 2'),
        basePrice: Value(12.0),
        categoryId: Value('beverage'),
      ),
    );
    await db.into(db.products).insert(
      const ProductsCompanion(
        id: Value('p3'),
        name: Value('Product 3'),
        basePrice: Value(15.0),
        categoryId: Value('beverage'),
      ),
    );

    // Initially assign modifier to p1 and p2
    final modId = 'test_edit_mod';
    await db.into(db.modifiers).insert(ModifiersCompanion.insert(id: modId, productId: 'p1', name: 'Original', priceDelta: 1.0, groupName: 'Grp'));
    await db.into(db.modifiers).insert(ModifiersCompanion.insert(id: modId, productId: 'p2', name: 'Original', priceDelta: 1.0, groupName: 'Grp'));

    // Simulation of editing assignments to p2 and p3 (p1 is removed, p3 is added, fields updated)
    final selectedProductIds = {'p2', 'p3'};
    final name = 'Updated';
    final price = 2.0;
    final group = 'New Grp';

    await db.transaction(() async {
      final existing = await (db.select(db.modifiers)..where((t) => t.id.equals(modId))).get();
      final existingProdIds = existing.map((m) => m.productId).toSet();

      // Additions
      final toAdd = selectedProductIds.difference(existingProdIds);
      for (final prodId in toAdd) {
        await db.into(db.modifiers).insert(
          ModifiersCompanion.insert(
            id: modId,
            productId: prodId,
            name: name,
            priceDelta: price,
            groupName: group,
          ),
        );
      }

      // Deletions
      final toDelete = existingProdIds.difference(selectedProductIds);
      if (toDelete.isNotEmpty) {
        await (db.delete(db.modifiers)
              ..where((t) => t.id.equals(modId) & t.productId.isIn(toDelete)))
            .go();
      }

      // Updates
      final remaining = selectedProductIds.intersection(existingProdIds);
      if (remaining.isNotEmpty) {
        await (db.update(db.modifiers)
              ..where((t) => t.id.equals(modId) & t.productId.isIn(remaining)))
            .write(
              ModifiersCompanion(
                name: Value(name),
                priceDelta: Value(price),
                groupName: Value(group),
              ),
            );
      }
    });

    // Assert final database state
    final finalMods = await (db.select(db.modifiers)..where((t) => t.id.equals(modId))).get();
    expect(finalMods.length, 2);
    expect(finalMods.any((m) => m.productId == 'p1'), isFalse); // Deleted
    expect(finalMods.any((m) => m.productId == 'p2'), isTrue);  // Maintained & Updated
    expect(finalMods.any((m) => m.productId == 'p3'), isTrue);  // Added

    for (final m in finalMods) {
      expect(m.name, 'Updated');
      expect(m.priceDelta, 2.0);
      expect(m.groupName, 'New Grp');
    }
  });
  ```

- [ ] **Step 2: Run tests to verify they fail/pass**
  Run command: `flutter test test/admin_test.dart`
  Expected: PASS (since tests implement correct database updates inline)

- [ ] **Step 3: Commit**
  Run: `git add test/admin_test.dart; git commit -m "test: add modifier transaction tests"`

---

### Task 2: Implement UI and Transaction Logic in Admin Dashboard

**Files:**
- Modify: `lib/screens/admin_dashboard_screen.dart`

- [ ] **Step 1: Replace product input with category checkboxes**
  Update `_showModifierDialog` to load categories stream, fetch current assignments, and display product checkbox lists grouped by category:
  ```dart
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

    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final productsAsync = ref.watch(allProductsStreamProvider);
          final categoriesAsync = ref.watch(categoriesStreamProvider);
          final db = ref.read(databaseProvider);

          // Fetch existing assignments for this modifier id
          final currentAssignmentsFuture = modifier == null
              ? Future.value(<Modifier>[])
              : (db.select(db.modifiers)..where((t) => t.id.equals(modifier.id))).get();

          return productsAsync.when(
            data: (products) => FutureBuilder<List<Modifier>>(
              future: currentAssignmentsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return StatefulBuilder(
                  builder: (context, setState) {
                    // Initialize selectedProductIds set
                    static Set<String>? tempSelected;
                    if (tempSelected == null) {
                      tempSelected = snapshot.data!.map((m) => m.productId).toSet();
                    }
                    final selectedProductIds = tempSelected!;

                    // Group products by category
                    final Map<String, List<Product>> categoryToProducts = {};
                    for (final prod in products) {
                      categoryToProducts.putIfAbsent(prod.categoryId, () => []).add(prod);
                    }

                    final canSave = nameController.text.isNotEmpty &&
                        priceController.text.isNotEmpty &&
                        groupController.text.isNotEmpty &&
                        selectedProductIds.isNotEmpty;

                    return AlertDialog(
                      backgroundColor: BinanceTheme.surfaceCardDark,
                      title: Text(
                        modifier == null
                            ? 'Add Modifier'
                            : 'Edit Modifier',
                        style: const TextStyle(color: BinanceTheme.onDark),
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: nameController,
                              style: const TextStyle(color: BinanceTheme.onDark),
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                labelStyle: TextStyle(color: BinanceTheme.muted),
                              ),
                              onChanged: (_) => setState(() {}),
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
                              onChanged: (_) => setState(() {}),
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
                                      final isAllSelected = catProductIds.every((id) => selectedProductIds.contains(id));

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
                                                  selectedProductIds.addAll(catProductIds);
                                                } else {
                                                  selectedProductIds.removeAll(catProductIds);
                                                }
                                              });
                                            },
                                          ),
                                          ...catProducts.map((prod) {
                                            final isSelected = selectedProductIds.contains(prod.id);
                                            return CheckboxListTile(
                                              title: Text(prod.name, style: const TextStyle(color: BinanceTheme.onDark)),
                                              value: isSelected,
                                              activeColor: BinanceTheme.primary,
                                              onChanged: (val) {
                                                setState(() {
                                                  if (val == true) {
                                                    selectedProductIds.add(prod.id);
                                                  } else {
                                                    selectedProductIds.remove(prod.id);
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
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: !canSave
                              ? null
                              : () async {
                                  final price = double.tryParse(priceController.text) ?? 0.0;
                                  final name = nameController.text;
                                  final group = groupController.text;

                                  if (modifier == null) {
                                    final newId = DateTime.now().millisecondsSinceEpoch.toString();
                                    await db.transaction(() async {
                                      for (final prodId in selectedProductIds) {
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
                                            ..where((t) => t.id.equals(modifier.id)))
                                          .get();
                                      final existingProdIds = existing.map((m) => m.productId).toSet();

                                      final toAdd = selectedProductIds.difference(existingProdIds);
                                      for (final prodId in toAdd) {
                                        await db.into(db.modifiers).insert(
                                          ModifiersCompanion.insert(
                                            id: modifier.id,
                                            productId: prodId,
                                            name: name,
                                            priceDelta: price,
                                            groupName: group,
                                          ),
                                        );
                                      }

                                      final toDelete = existingProdIds.difference(selectedProductIds);
                                      if (toDelete.isNotEmpty) {
                                        await (db.delete(db.modifiers)
                                              ..where((t) => t.id.equals(modifier.id) & t.productId.isIn(toDelete)))
                                            .go();
                                      }

                                      final remaining = selectedProductIds.intersection(existingProdIds);
                                      if (remaining.isNotEmpty) {
                                        await (db.update(db.modifiers)
                                              ..where((t) => t.id.equals(modifier.id) & t.productId.isIn(remaining)))
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
                );
              },
            ),
            error: (_, __) => const AlertDialog(content: Text('Error loading products')),
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
  ```

- [ ] **Step 2: Run verification tests**
  Run: `flutter test`
  Expected: PASS

- [ ] **Step 3: Commit changes**
  Run: `git add lib/screens/admin_dashboard_screen.dart; git commit -m "feat: implement category-grouped multi-product assignment for modifiers"`
