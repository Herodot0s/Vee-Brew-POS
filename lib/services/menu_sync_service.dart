import '../database/drift_database.dart';
import '../models/mock_data.dart';
import 'package:drift/drift.dart';

class MenuSyncService {
  static Future<void> syncMenuFromMarkdown(AppDatabase db, String content) async {
    try {
      await db.transaction(() async {
        await db.delete(db.modifiers).go();
        await db.delete(db.products).go();
        await db.delete(db.categories).go();

        final lines = content.split('\n');
        String? currentCategory;
        String? currentCategoryId;
        List<String> activeCategoryIds = [];
        Map<String, List<double?>> categoryPrices = {};
        double? currentPriceMed;
        double? currentPriceLrg;
        double? currentPriceLiter;
        bool parsingFlavors = false;

        for (int i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;

          // Parse Categories
          if (line.startsWith('## ')) {
            currentCategory = line.substring(3).trim();
            parsingFlavors = false;

            // Reset prices
            currentPriceMed = null;
            currentPriceLrg = null;
            currentPriceLiter = null;

            currentCategoryId = _mapCategoryToId(currentCategory);
            activeCategoryIds = [currentCategoryId];

            await db.into(db.categories).insert(
                  CategoriesCompanion.insert(
                    id: currentCategoryId,
                    name: currentCategory,
                    sortOrder: i,
                  ),
                );
            continue;
          }

          // Parse Prices (Markdown Tables)
          if (line.startsWith('|') && line.contains('Price')) {
            if (i + 2 < lines.length) {
              final nextLine = lines[i + 2];
              if (nextLine.contains('Medium')) {
                currentPriceMed = _extractPrice(nextLine);
                if (i + 3 < lines.length) {
                  final largeLine = lines[i + 3];
                  currentPriceLrg = _extractPrice(largeLine);
                }
                if (i + 4 < lines.length && lines[i + 4].contains('1 Liter')) {
                  currentPriceLiter = _extractPrice(lines[i + 4]);
                }
              }
            }
            if (currentCategoryId != null) {
              categoryPrices[currentCategoryId] = [currentPriceMed, currentPriceLrg, currentPriceLiter];
            }
            continue;
          }

          // Detect flavor tables
          if (line.startsWith('### Flavors') || line.startsWith('### Fruit Tea Flavors')) {
            parsingFlavors = true;
            if (line.startsWith('### Fruit Tea Flavors')) {
              activeCategoryIds = ['fruit_tea_tea', 'fruit_tea_water'];
            }
            continue;
          }

          // Parse Flavors (Products)
          if (parsingFlavors && line.startsWith('|') && !line.contains('---') && !line.contains('Column')) {
            await _parseFlavorLine(db, line, activeCategoryIds, categoryPrices, currentPriceMed, currentPriceLrg, currentPriceLiter);
            continue;
          }

          // Special handling for Premium Frappe and Fries (inline price tables)
          if ((currentCategory == 'Premium Frappe' || currentCategory == 'Fries') &&
              line.startsWith('|') &&
              !line.contains('---') &&
              !line.contains('Flavor') &&
              !line.contains('Price')) {
            await _parseSpecialCategoryLine(db, line, currentCategory, currentCategoryId);
          }
        }
      });
    } catch (e) {
      print('Error syncing menu: $e');
      rethrow;
    }
  }

  static Future<void> _parseFlavorLine(
    AppDatabase db,
    String line,
    List<String> activeCategoryIds,
    Map<String, List<double?>> categoryPrices,
    double? currentPriceMed,
    double? currentPriceLrg,
    double? currentPriceLiter,
  ) async {
    final parts = line.split('|').where((s) => s.trim().isNotEmpty).toList();
    await db.batch((batch) {
      for (final flavor in parts) {
        final trimmedFlavor = flavor.trim();
        if (trimmedFlavor.isEmpty || trimmedFlavor.contains('Flavors')) continue;

        for (final catId in activeCategoryIds) {
          final productId = _generateProductId(catId, trimmedFlavor);
          final catName = _getCategoryNameFromId(catId);
          final productName = _generateProductName(catName, trimmedFlavor);
          final prices = categoryPrices[catId] ?? [currentPriceMed, currentPriceLrg, currentPriceLiter];

          batch.insert(
            db.products,
            ProductsCompanion.insert(
              id: productId,
              name: productName,
              basePrice: prices[0] ?? 0.0,
              categoryId: catId,
            ),
            mode: InsertMode.insertOrReplace,
          );

          _addStandardModifiersToBatch(batch, db, productId, catId, prices[0], prices[1], prices[2]);

          if (catId != 'fries' && catId != 'hot_brew') {
            for (final addon in mockAddOns) {
              batch.insert(
                db.modifiers,
                ModifiersCompanion.insert(
                  id: addon.id,
                  productId: productId,
                  name: addon.name,
                  priceDelta: addon.priceDelta,
                  groupName: 'Addons',
                ),
                mode: InsertMode.insertOrReplace,
              );
            }
          }
        }
      }
    });
  }

  static Future<void> _parseSpecialCategoryLine(AppDatabase db, String line, String? currentCategory, String? currentCategoryId) async {
    final parts = line.split('|').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (parts.length < 2 || currentCategoryId == null) return;

    final flavor = parts[0];
    final price = double.tryParse(parts[1]) ?? 0.0;
    final productId = _generateProductId(currentCategoryId, flavor);
    final productName = flavor + (currentCategory == 'Premium Frappe' ? ' Premium' : ' Fries');

    await db.into(db.products).insert(
          ProductsCompanion.insert(
            id: productId,
            name: productName,
            basePrice: price,
            categoryId: currentCategoryId,
          ),
          mode: InsertMode.insertOrReplace,
        );

    if (currentCategory == 'Premium Frappe') {
      final priceLarge = parts.length > 2 ? double.tryParse(parts[2]) : null;
      await db.batch((batch) {
        _addStandardModifiersToBatch(batch, db, productId, currentCategoryId, price, priceLarge, null);
        for (final addon in mockAddOns) {
          batch.insert(
            db.modifiers,
            ModifiersCompanion.insert(
              id: addon.id,
              productId: productId,
              name: addon.name,
              priceDelta: addon.priceDelta,
              groupName: 'Addons',
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    } else if (currentCategory == 'Fries') {
      final medPrice = parts.length > 2 ? double.tryParse(parts[2]) : null;
      final lrgPrice = parts.length > 3 ? double.tryParse(parts[3]) : null;
      final jmbPrice = parts.length > 4 ? double.tryParse(parts[4]) : null;

      await db.batch((batch) {
        batch.insert(db.modifiers, ModifiersCompanion.insert(id: 'sz_small', productId: productId, name: 'Small', priceDelta: 0.0, groupName: 'Size Selection'));
        if (medPrice != null) {
          batch.insert(db.modifiers, ModifiersCompanion.insert(id: 'sz_medium', productId: productId, name: 'Medium', priceDelta: medPrice - price, groupName: 'Size Selection'));
        }
        if (lrgPrice != null) {
          batch.insert(db.modifiers, ModifiersCompanion.insert(id: 'sz_large', productId: productId, name: 'Large', priceDelta: lrgPrice - price, groupName: 'Size Selection'));
        }
        if (jmbPrice != null) {
          batch.insert(db.modifiers, ModifiersCompanion.insert(id: 'sz_jumbo', productId: productId, name: 'Jumbo', priceDelta: jmbPrice - price, groupName: 'Size Selection'));
        }
      });
    }
  }

  static String _mapCategoryToId(String name) {
    switch (name) {
      case 'Milk Tea':
        return 'milk_tea';
      case 'Cheesecake':
        return 'cheesecake';
      case 'Fruit Tea - Tea Based':
        return 'fruit_tea_tea';
      case 'Fruit Tea - Water Based':
        return 'fruit_tea_water';
      case 'Cold Brew':
        return 'cold_brew';
      case 'Hot Brew':
        return 'hot_brew';
      case 'Premium Frappe':
        return 'premium_frappe';
      case 'Fries':
        return 'fries';
      case 'Frappe - Coffee Based':
        return 'frappe_coffee';
      case 'Frappe - Non-Coffee Based':
        return 'frappe_non_coffee';
      default:
        return name.toLowerCase().replaceAll(' ', '_');
    }
  }

  static String _getCategoryNameFromId(String id) {
    switch (id) {
      case 'milk_tea':
        return 'Milk Tea';
      case 'cheesecake':
        return 'Cheesecake';
      case 'fruit_tea_tea':
        return 'Fruit Tea - Tea Based';
      case 'fruit_tea_water':
        return 'Fruit Tea - Water Based';
      case 'cold_brew':
        return 'Cold Brew';
      case 'hot_brew':
        return 'Hot Brew';
      case 'premium_frappe':
        return 'Premium Frappe';
      case 'fries':
        return 'Fries';
      case 'frappe_coffee':
        return 'Frappe - Coffee Based';
      case 'frappe_non_coffee':
        return 'Frappe - Non-Coffee Based';
      default:
        return id;
    }
  }

  static double _extractPrice(String line) {
    final match = RegExp(r'\|\s*[^|]+\s*\|\s*(\d+)\s*\|').firstMatch(line);
    if (match == null || match.groupCount < 1) return 0.0;
    return double.tryParse(match.group(1) ?? '0') ?? 0.0;
  }

  static String _generateProductId(String catId, String flavor) {
    final prefix = {
          'milk_tea': 'mt',
          'cheesecake': 'cc',
          'fruit_tea_tea': 'ftt',
          'fruit_tea_water': 'ftw',
          'cold_brew': 'cb',
          'hot_brew': 'hb',
          'premium_frappe': 'pf',
          'fries': 'fr',
          'frappe_coffee': 'fc',
          'frappe_non_coffee': 'fnc',
        }[catId] ??
        catId;
    return '${prefix}_${flavor.toLowerCase().replaceAll(' ', '_').replaceAll('&', 'n')}';
  }

  static String _generateProductName(String catName, String flavor) {
    if (catName.contains('Milk Tea')) return '$flavor Milk Tea';
    if (catName.contains('Cheesecake')) return '$flavor Cheesecake';
    if (catName.contains('Fruit Tea')) {
      final base = catName.contains('Tea Based') ? '(Tea)' : '(Water)';
      return '$flavor Fruit Tea $base';
    }
    if (catName.contains('Cold Brew')) return flavor.startsWith('Iced') ? flavor : 'Iced $flavor';
    if (catName.contains('Hot Brew')) return flavor.startsWith('Hot') ? flavor : 'Hot $flavor';
    if (catName.contains('Frappe')) return '$flavor Frappe';
    return flavor;
  }

  static void _addStandardModifiersToBatch(
    Batch batch,
    AppDatabase db,
    String productId,
    String catId,
    double? med,
    double? lrg,
    double? liter,
  ) {
    if (catId == 'fries') return;

    // Size
    if (med != null && lrg != null) {
      batch.insert(db.modifiers, ModifiersCompanion.insert(id: 'sz_med', productId: productId, name: 'Medium', priceDelta: 0.0, groupName: 'Size Selection'),
          mode: InsertMode.insertOrReplace);
      batch.insert(db.modifiers, ModifiersCompanion.insert(id: 'sz_lrg', productId: productId, name: 'Large', priceDelta: lrg - med, groupName: 'Size Selection'),
          mode: InsertMode.insertOrReplace);
      if (liter != null) {
        batch.insert(db.modifiers, ModifiersCompanion.insert(id: 'sz_liter', productId: productId, name: '1 Liter', priceDelta: liter - med, groupName: 'Size Selection'),
            mode: InsertMode.insertOrReplace);
      }
    }

    if (catId == 'hot_brew') return;

    // Sugar
    for (final level in ['100% Sugar', '75% Sugar', '50% Sugar', '25% Sugar', '0% Sugar']) {
      batch.insert(
        db.modifiers,
        ModifiersCompanion.insert(id: 's_${level.split('%')[0]}', productId: productId, name: level, priceDelta: 0.0, groupName: 'Sugar Level'),
        mode: InsertMode.insertOrReplace,
      );
    }

    // Ice
    for (final level in ['Normal Ice', 'Less Ice', 'No Ice']) {
      batch.insert(
        db.modifiers,
        ModifiersCompanion.insert(id: 'i_${level.split(' ')[0].toLowerCase()}', productId: productId, name: level, priceDelta: 0.0, groupName: 'Ice Level'),
        mode: InsertMode.insertOrReplace,
      );
    }
  }
}
