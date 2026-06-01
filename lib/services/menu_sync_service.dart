import '../database/drift_database.dart';
import '../models/mock_data.dart';

class MenuSyncService {
  static Future<void> syncMenuFromMarkdown(AppDatabase db, String content) async {
    await db.transaction(() async {
      await db.delete(db.modifiers).go();
      await db.delete(db.products).go();
      await db.delete(db.categories).go();

      final lines = content.split('\n');
      String? currentCategory;
      String? currentCategoryId;
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

          // Map category name to ID
          currentCategoryId = _mapCategoryToId(currentCategory);

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
          final nextLine = lines[i+2]; // Skip header separator
          if (nextLine.contains('Medium')) {
            currentPriceMed = _extractPrice(nextLine);
            final largeLine = lines[i+3];
            currentPriceLrg = _extractPrice(largeLine);
            if (i + 4 < lines.length && lines[i+4].contains('1 Liter')) {
              currentPriceLiter = _extractPrice(lines[i+4]);
            }
          }
          continue;
        }

        // Detect flavor tables
        if (line.startsWith('### Flavors') || line.startsWith('### Fruit Tea Flavors')) {
          parsingFlavors = true;
          continue;
        }

        // Parse Flavors (Products)
        if (parsingFlavors && line.startsWith('|') && !line.contains('---') && !line.contains('Column')) {
          final parts = line.split('|').where((s) => s.trim().isNotEmpty).toList();
          for (final flavor in parts) {
            final trimmedFlavor = flavor.trim();
            if (trimmedFlavor.isEmpty || trimmedFlavor.contains('Flavors')) continue;

            final productId = _generateProductId(currentCategoryId!, trimmedFlavor);
            final productName = _generateProductName(currentCategory!, trimmedFlavor);

            await db.into(db.products).insert(
              ProductsCompanion.insert(
                id: productId,
                name: productName,
                basePrice: currentPriceMed ?? 0.0,
                categoryId: currentCategoryId,
              ),
            );

            // Add standard modifiers (Size, Sugar, Ice)
            await _addStandardModifiers(db, productId, currentCategoryId, currentPriceMed, currentPriceLrg, currentPriceLiter);

            // Add global addons for beverages
            if (currentCategoryId != 'fries' && currentCategoryId != 'hot_brew') {
              for (final addon in mockAddOns) {
                await db.into(db.modifiers).insert(
                  ModifiersCompanion.insert(
                    id: addon.id,
                    productId: productId,
                    name: addon.name,
                    priceDelta: addon.priceDelta,
                    groupName: 'Addons',
                  ),
                );
              }
            }
          }
        }

        // Special handling for Premium Frappe and Fries (inline price tables)
        if ((currentCategory == 'Premium Frappe' || currentCategory == 'Fries') &&
            line.startsWith('|') && !line.contains('---') && !line.contains('Flavor')) {
          final parts = line.split('|').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
          if (parts.length >= 2) {
            final flavor = parts[0];
            final price = double.tryParse(parts[1]) ?? 0.0;

            final productId = _generateProductId(currentCategoryId!, flavor);
            final productName = flavor + (currentCategory == 'Premium Frappe' ? ' Premium' : ' Fries');

            await db.into(db.products).insert(
              ProductsCompanion.insert(
                id: productId,
                name: productName,
                basePrice: price,
                categoryId: currentCategoryId,
              ),
            );

            if (currentCategory == 'Premium Frappe') {
              final priceLarge = double.tryParse(parts[2]) ?? 0.0;
              await _addStandardModifiers(db, productId, currentCategoryId, price, priceLarge, null);

              // Add addons
              for (final addon in mockAddOns) {
                await db.into(db.modifiers).insert(
                  ModifiersCompanion.insert(
                    id: addon.id,
                    productId: productId,
                    name: addon.name,
                    priceDelta: addon.priceDelta,
                    groupName: 'Addons',
                  ),
                );
              }
            } else if (currentCategory == 'Fries') {
              // Size modifiers for fries
              final medPrice = double.tryParse(parts[2]) ?? 0.0;
              final lrgPrice = double.tryParse(parts[3]) ?? 0.0;
              final jmbPrice = double.tryParse(parts[4]) ?? 0.0;

              await db.batch((batch) {
                batch.insert(db.modifiers, ModifiersCompanion.insert(id: 'sz_small', productId: productId, name: 'Small', priceDelta: 0.0, groupName: 'Size Selection'));
                batch.insert(db.modifiers, ModifiersCompanion.insert(id: 'sz_medium', productId: productId, name: 'Medium', priceDelta: medPrice - price, groupName: 'Size Selection'));
                batch.insert(db.modifiers, ModifiersCompanion.insert(id: 'sz_large', productId: productId, name: 'Large', priceDelta: lrgPrice - price, groupName: 'Size Selection'));
                batch.insert(db.modifiers, ModifiersCompanion.insert(id: 'sz_jumbo', productId: productId, name: 'Jumbo', priceDelta: jmbPrice - price, groupName: 'Size Selection'));
              });
            }
          }
        }
      }
    });
  }

  static String _mapCategoryToId(String name) {
    switch (name) {
      case 'Milk Tea': return 'milk_tea';
      case 'Cheesecake': return 'cheesecake';
      case 'Fruit Tea - Tea Based': return 'fruit_tea_tea';
      case 'Fruit Tea - Water Based': return 'fruit_tea_water';
      case 'Cold Brew': return 'cold_brew';
      case 'Hot Brew': return 'hot_brew';
      case 'Premium Frappe': return 'premium_frappe';
      case 'Fries': return 'fries';
      case 'Frappe - Coffee Based': return 'frappe_coffee';
      case 'Frappe - Non-Coffee Based': return 'frappe_non_coffee';
      default: return name.toLowerCase().replaceAll(' ', '_');
    }
  }

  static double _extractPrice(String line) {
    final match = RegExp(r'\|\s*[^|]+\s*\|\s*(\d+)\s*\|').firstMatch(line);
    return double.tryParse(match?.group(1) ?? '0') ?? 0.0;
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
    }[catId] ?? catId;
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

  static Future<void> _addStandardModifiers(AppDatabase db, String productId, String catId, double? med, double? lrg, double? liter) async {
    if (catId == 'fries') return;

    // Size
    if (med != null && lrg != null) {
      await db.into(db.modifiers).insert(ModifiersCompanion.insert(id: 'sz_med', productId: productId, name: 'Medium', priceDelta: 0.0, groupName: 'Size Selection'));
      await db.into(db.modifiers).insert(ModifiersCompanion.insert(id: 'sz_lrg', productId: productId, name: 'Large', priceDelta: lrg - med, groupName: 'Size Selection'));
      if (liter != null) {
        await db.into(db.modifiers).insert(ModifiersCompanion.insert(id: 'sz_liter', productId: productId, name: '1 Liter', priceDelta: liter - med, groupName: 'Size Selection'));
      }
    }

    if (catId == 'hot_brew') return;

    // Sugar
    for (final level in ['100% Sugar', '75% Sugar', '50% Sugar', '25% Sugar', '0% Sugar']) {
      await db.into(db.modifiers).insert(ModifiersCompanion.insert(id: 's_${level.split('%')[0]}', productId: productId, name: level, priceDelta: 0.0, groupName: 'Sugar Level'));
    }

    // Ice
    for (final level in ['Normal Ice', 'Less Ice', 'No Ice']) {
      await db.into(db.modifiers).insert(ModifiersCompanion.insert(id: 'i_${level.split(' ')[0].toLowerCase()}', productId: productId, name: level, priceDelta: 0.0, groupName: 'Ice Level'));
    }
  }
}
