import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/drift_database.dart';
import '../providers/database_provider.dart';
import '../providers/category_provider.dart';
import '../models/modifier.dart';

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.categories,
  )..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).watch();
});

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  () => SearchQueryNotifier(),
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final db = ref.watch(databaseProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  return (db.select(db.products)..where((t) {
        if (query.isNotEmpty) {
          return t.name.like('%$query%');
        }
        return t.categoryId.equals(selectedCategory);
      }))
      .watch();
});

final modifiersStreamProvider = StreamProvider<List<Modifier>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.modifiers)).watch();
});

final productModifiersProvider = StreamProvider.family<List<ModifierGroup>, String>((ref, productId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.modifiers)..where((t) => t.productId.equals(productId)))
      .watch()
      .map((dbModifiers) {
        final Map<String, List<ModifierOption>> groupsMap = {};

        for (final m in dbModifiers) {
          final groupName = m.groupName;
          final opt = ModifierOption(
            id: m.id,
            groupId: groupName.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_'),
            name: m.name,
            priceDelta: m.priceDelta,
            isDefault: m.id == 'sz_small' || m.id == 'sz_med' || m.id == 's_100' || m.id == 'i_normal',
          );
          groupsMap.putIfAbsent(groupName, () => []).add(opt);
        }

        const groupOrder = ['Size Selection', 'Sugar Level', 'Ice Level', 'Addons', 'Add-ons'];
        final List<ModifierGroup> groups = [];

        for (final name in groupOrder) {
          if (groupsMap.containsKey(name)) {
            final options = groupsMap[name]!;

            // Sort options inside group
            if (name == 'Size Selection') {
              const order = ['Small', 'Medium', 'Large', '1 Liter', 'Jumbo'];
              options.sort((a, b) {
                final idxA = order.indexOf(a.name);
                final idxB = order.indexOf(b.name);
                if (idxA != -1 && idxB != -1) return idxA.compareTo(idxB);
                return a.name.compareTo(b.name);
              });
            } else if (name == 'Sugar Level') {
              const order = ['100% Sugar', '75% Sugar', '50% Sugar', '25% Sugar', '0% Sugar'];
              options.sort((a, b) {
                final idxA = order.indexOf(a.name);
                final idxB = order.indexOf(b.name);
                if (idxA != -1 && idxB != -1) return idxA.compareTo(idxB);
                return a.name.compareTo(b.name);
              });
            } else if (name == 'Ice Level') {
              const order = ['Normal Ice', 'Less Ice', 'No Ice'];
              options.sort((a, b) {
                final idxA = order.indexOf(a.name);
                final idxB = order.indexOf(b.name);
                if (idxA != -1 && idxB != -1) return idxA.compareTo(idxB);
                return a.name.compareTo(b.name);
              });
            } else {
              options.sort((a, b) => a.name.compareTo(b.name));
            }

            final isRequired = name != 'Addons' && name != 'Add-ons';
            final isMultiSelect = name == 'Addons' || name == 'Add-ons';

            groups.add(ModifierGroup(
              id: name.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_'),
              productId: productId,
              name: name,
              isRequired: isRequired,
              isMultiSelect: isMultiSelect,
              options: options,
            ));
          }
        }

        // Add any other groups not in our order list
        groupsMap.forEach((name, options) {
          if (!groupOrder.contains(name)) {
            options.sort((a, b) => a.name.compareTo(b.name));
            groups.add(ModifierGroup(
              id: name.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_'),
              productId: productId,
              name: name,
              isRequired: false,
              isMultiSelect: false,
              options: options,
            ));
          }
        });

        return groups;
      });
});

enum TimeRange { day, week, month, year }

final allProductsStreamProvider = StreamProvider<List<Product>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.products)..orderBy([(t) => OrderingTerm(expression: t.name)])).watch();
});
