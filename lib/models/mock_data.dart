import 'package:flutter/material.dart';
import 'product.dart';
import 'modifier.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;

  const Category({required this.id, required this.name, required this.icon});
}

const List<Category> mockCategories = [
  Category(id: 'milk_tea', name: 'Milk Tea', icon: Icons.local_drink),
  Category(id: 'cheesecake', name: 'Cheesecake', icon: Icons.cake),
  Category(id: 'fruit_tea_tea', name: 'Fruit Tea (Tea)', icon: Icons.emoji_food_beverage),
  Category(id: 'fruit_tea_water', name: 'Fruit Tea (Water)', icon: Icons.water_drop),
  Category(id: 'cold_brew', name: 'Cold Brew', icon: Icons.ac_unit),
  Category(id: 'hot_brew', name: 'Hot Brew', icon: Icons.coffee),
  Category(id: 'premium_frappe', name: 'Prem. Frappe', icon: Icons.icecream),
  Category(id: 'frappe_coffee', name: 'Frappe (Coffee)', icon: Icons.coffee_maker),
  Category(id: 'frappe_non_coffee', name: 'Frappe (No-Coffee)', icon: Icons.restaurant),
  Category(id: 'fries', name: 'Fries', icon: Icons.fastfood),
];

final List<Product> mockProducts = [
  // Milk Tea (Base Med: 28)
  ...[
    'Wintermelon', 'Salted Caramel', 'Okinawa', 'Choco Strawberry', 'Matcha', 'Red Velvet',
    'Mango', 'Very Rocky Road', 'Avocado', 'Double Dutch', 'Blueberry', 'Strawberry',
    'Black Forest', 'Taro', 'Hokkaido', 'Dark Chocolate', 'Hazel Nut', 'Cookies & Cream'
  ].map((f) => Product(id: 'mt_${f.toLowerCase().replaceAll(' ', '_')}', name: '$f Milk Tea', basePrice: 28.0, categoryId: 'milk_tea')),

  // Cheesecake (Base Med: 43)
  ...[
    'Wintermelon', 'Salted Caramel', 'Okinawa', 'Choco Strawberry', 'Matcha', 'Red Velvet',
    'Mango', 'Very Rocky Road', 'Avocado', 'Double Dutch', 'Blueberry', 'Strawberry',
    'Black Forest', 'Taro', 'Hokkaido', 'Dark Chocolate', 'Hazel Nut', 'Cookies & Cream'
  ].map((f) => Product(id: 'cc_${f.toLowerCase().replaceAll(' ', '_')}', name: '$f Cheesecake', basePrice: 43.0, categoryId: 'cheesecake')),

  // Fruit Tea (Tea Based: 45, Water Based: 35)
  ...[
    'Kiwiberry', 'Lychee', 'Lemon', 'Mango', 'Peach', 'Passion', 'Strawberry', 'Blueberry',
    'Green Apple', 'Peach Mango', 'Mixed Berries', 'Melon', 'Four Season'
  ].expand((f) => [
    Product(id: 'ftt_${f.toLowerCase().replaceAll(' ', '_')}', name: '$f Fruit Tea (Tea)', basePrice: 45.0, categoryId: 'fruit_tea_tea'),
    Product(id: 'ftw_${f.toLowerCase().replaceAll(' ', '_')}', name: '$f Fruit Tea (Water)', basePrice: 35.0, categoryId: 'fruit_tea_water'),
  ]),

  // Cold Brew (Base Med: 45)
  ...[
    'Americano', 'Chocolate', 'Spanish Latte', 'White Mocha', 'Mocha Latte', 'French Vanilla',
    'Java Latte', 'Salted Caramel Latte', 'Cappuccino Latte', 'Caramel Sugar', 'Matcha Latte',
    'Caramel Macchiato'
  ].map((f) => Product(id: 'cb_${f.toLowerCase().replaceAll(' ', '_')}', name: 'Iced $f', basePrice: 45.0, categoryId: 'cold_brew')),

  // Hot Brew (Fixed: 45)
  ...[
    'Americano', 'Chocolate', 'Spanish Latte', 'White Mocha', 'Mocha Latte', 'French Vanilla',
    'Java Latte', 'Salted Caramel Latte', 'Cappuccino Latte', 'Caramel Sugar', 'Matcha Latte',
    'Caramel Macchiato'
  ].map((f) => Product(id: 'hb_${f.toLowerCase().replaceAll(' ', '_')}', name: 'Hot $f', basePrice: 45.0, categoryId: 'hot_brew')),

  // Premium Frappe (Mixed Base)
  Product(id: 'pf_cookies_cream', name: 'Cookies & Cream Premium', basePrice: 65.0, categoryId: 'premium_frappe'),
  Product(id: 'pf_mango_graham', name: 'Mango Graham Premium', basePrice: 55.0, categoryId: 'premium_frappe'),

  // Frappe Coffee (Base Med: 45)
  ...['Dark Caramel', 'Dark Cappuccino', 'Dark Mocha', 'Java Chip'].map((f) => Product(id: 'fc_${f.toLowerCase().replaceAll(' ', '_')}', name: '$f Frappe', basePrice: 45.0, categoryId: 'frappe_coffee')),

  // Frappe Non-Coffee (Base Med: 45)
  ...[
    'Matcha', 'Rocky Road', 'Taro', 'Double Dutch', 'Mango', 'Triple Chocolate', 'Avocado',
    'Dark Choco Berry', 'Red Velvet', 'Blueberry', 'Green Apple', 'Strawberries & Cream',
    'Peach Mango', 'Mixed Berries'
  ].map((f) => Product(id: 'fnc_${f.toLowerCase().replaceAll(' ', '_')}', name: '$f Frappe (Non-Coffee)', basePrice: 45.0, categoryId: 'frappe_non_coffee')),

  // Fries (Base Small)
  Product(id: 'fr_plain', name: 'Plain Fries', basePrice: 30.0, categoryId: 'fries'),
  Product(id: 'fr_cheese', name: 'Cheese Fries', basePrice: 30.0, categoryId: 'fries'),
  Product(id: 'fr_sour_cream', name: 'Sour & Cream Fries', basePrice: 40.0, categoryId: 'fries'),
];

List<ModifierGroup> getModifierGroupsForProduct(Product product) {
  if (product.categoryId == 'fries') {
    double medDelta = 30.0;
    double lrgDelta = 60.0;
    double jmbDelta = 90.0;

    if (product.id == 'fr_cheese') {
      medDelta = 10.0;
      lrgDelta = 30.0;
      jmbDelta = 130.0;
    } else if (product.id == 'fr_sour_cream') {
      medDelta = 20.0;
      lrgDelta = 60.0;
      jmbDelta = 140.0;
    }

    return [
      ModifierGroup(
        id: 'fries_size',
        productId: product.id,
        name: 'Size Selection',
        isRequired: true,
        options: [
          ModifierOption(id: 'sz_small', groupId: 'fries_size', name: 'Small', priceDelta: 0.0, isDefault: true),
          ModifierOption(id: 'sz_medium', groupId: 'fries_size', name: 'Medium', priceDelta: medDelta),
          ModifierOption(id: 'sz_large', groupId: 'fries_size', name: 'Large', priceDelta: lrgDelta),
          ModifierOption(id: 'sz_jumbo', groupId: 'fries_size', name: 'Jumbo', priceDelta: jmbDelta),
        ],
      ),
    ];
  }

  if (product.categoryId == 'hot_brew') return [];

  List<ModifierOption> sizeOptions = [
    ModifierOption(id: 'sz_med', groupId: 'size', name: 'Medium', priceDelta: 0.0, isDefault: true),
    ModifierOption(id: 'sz_lrg', groupId: 'size', name: 'Large', priceDelta: (product.id == 'pf_cookies_cream' ? 20.0 : product.id == 'pf_mango_graham' ? 30.0 : 10.0)),
  ];

  if (product.categoryId == 'milk_tea' || product.categoryId == 'cheesecake' || product.categoryId.startsWith('fruit_tea')) {
    sizeOptions.add(ModifierOption(id: 'sz_liter', groupId: 'size', name: '1 Liter', priceDelta: 40.0));
  }

  return [
    ModifierGroup(id: 'size', productId: product.id, name: 'Size Selection', isRequired: true, options: sizeOptions),
    ModifierGroup(
      id: 'sugar',
      productId: product.id,
      name: 'Sugar Level',
      isRequired: true,
      options: [
        ModifierOption(id: 's_100', groupId: 'sugar', name: '100% Sugar', priceDelta: 0.0, isDefault: true),
        ModifierOption(id: 's_75', groupId: 'sugar', name: '75% Sugar', priceDelta: 0.0),
        ModifierOption(id: 's_50', groupId: 'sugar', name: '50% Sugar', priceDelta: 0.0),
        ModifierOption(id: 's_25', groupId: 'sugar', name: '25% Sugar', priceDelta: 0.0),
        ModifierOption(id: 's_0', groupId: 'sugar', name: '0% Sugar', priceDelta: 0.0),
      ],
    ),
    ModifierGroup(
      id: 'ice',
      productId: product.id,
      name: 'Ice Level',
      isRequired: true,
      options: [
        ModifierOption(id: 'i_normal', groupId: 'ice', name: 'Normal Ice', priceDelta: 0.0, isDefault: true),
        ModifierOption(id: 'i_less', groupId: 'ice', name: 'Less Ice', priceDelta: 0.0),
        ModifierOption(id: 'i_no', groupId: 'ice', name: 'No Ice', priceDelta: 0.0),
      ],
    ),
  ];
}

const List<ModifierOption> mockAddOns = [
  ModifierOption(id: 'add_pearl', groupId: 'addons', name: 'Pearl', priceDelta: 10.0),
  ModifierOption(id: 'add_nata', groupId: 'addons', name: 'Nata', priceDelta: 15.0),
  ModifierOption(id: 'add_coffee_jelly', groupId: 'addons', name: 'Coffee Jelly', priceDelta: 15.0),
  ModifierOption(id: 'add_cream_cheese', groupId: 'addons', name: 'Cream Cheese', priceDelta: 15.0),
  ModifierOption(id: 'add_oreo', groupId: 'addons', name: 'Crushed Oreo', priceDelta: 15.0),
  ModifierOption(id: 'add_graham', groupId: 'addons', name: 'Crushed Graham', priceDelta: 15.0),
  ModifierOption(id: 'add_foam', groupId: 'addons', name: 'Classic Foam', priceDelta: 15.0),
  ModifierOption(id: 'add_pudding', groupId: 'addons', name: 'Egg Pudding', priceDelta: 15.0),
];
