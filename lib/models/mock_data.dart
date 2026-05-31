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

const List<Product> mockProducts = [
  // Milk Tea
  Product(id: 'mt_wintermelon', name: 'Wintermelon Milk Tea', basePrice: 28.0, categoryId: 'milk_tea'),
  Product(id: 'mt_okinawa', name: 'Okinawa Milk Tea', basePrice: 28.0, categoryId: 'milk_tea'),
  Product(id: 'mt_matcha', name: 'Matcha Milk Tea', basePrice: 28.0, categoryId: 'milk_tea'),
  Product(id: 'mt_taro', name: 'Taro Milk Tea', basePrice: 28.0, categoryId: 'milk_tea'),
  Product(id: 'mt_dark_chocolate', name: 'Dark Chocolate Milk Tea', basePrice: 28.0, categoryId: 'milk_tea'),
  Product(id: 'mt_cookies_cream', name: 'Cookies & Cream Milk Tea', basePrice: 28.0, categoryId: 'milk_tea'),
  Product(id: 'mt_salted_caramel', name: 'Salted Caramel Milk Tea', basePrice: 28.0, categoryId: 'milk_tea'),
  Product(id: 'mt_hokkaido', name: 'Hokkaido Milk Tea', basePrice: 28.0, categoryId: 'milk_tea'),

  // Cheesecake
  Product(id: 'cc_wintermelon', name: 'Wintermelon Cheesecake', basePrice: 43.0, categoryId: 'cheesecake'),
  Product(id: 'cc_okinawa', name: 'Okinawa Cheesecake', basePrice: 43.0, categoryId: 'cheesecake'),
  Product(id: 'cc_matcha', name: 'Matcha Cheesecake', basePrice: 43.0, categoryId: 'cheesecake'),
  Product(id: 'cc_taro', name: 'Taro Cheesecake', basePrice: 43.0, categoryId: 'cheesecake'),
  Product(id: 'cc_red_velvet', name: 'Red Velvet Cheesecake', basePrice: 43.0, categoryId: 'cheesecake'),
  Product(id: 'cc_double_dutch', name: 'Double Dutch Cheesecake', basePrice: 43.0, categoryId: 'cheesecake'),

  // Fruit Tea (Tea)
  Product(id: 'ftt_kiwi', name: 'Kiwi Fruit Tea', basePrice: 45.0, categoryId: 'fruit_tea_tea'),
  Product(id: 'ftt_lychee', name: 'Lychee Fruit Tea', basePrice: 45.0, categoryId: 'fruit_tea_tea'),
  Product(id: 'ftt_lemon', name: 'Lemon Fruit Tea', basePrice: 45.0, categoryId: 'fruit_tea_tea'),
  Product(id: 'ftt_mango', name: 'Mango Fruit Tea', basePrice: 45.0, categoryId: 'fruit_tea_tea'),
  Product(id: 'ftt_passion', name: 'Passion Fruit Tea', basePrice: 45.0, categoryId: 'fruit_tea_tea'),

  // Fruit Tea (Water)
  Product(id: 'ftw_blueberry', name: 'Blueberry Fruit Tea', basePrice: 35.0, categoryId: 'fruit_tea_water'),
  Product(id: 'ftw_strawberry', name: 'Strawberry Fruit Tea', basePrice: 35.0, categoryId: 'fruit_tea_water'),
  Product(id: 'ftw_green_apple', name: 'Green Apple Fruit Tea', basePrice: 35.0, categoryId: 'fruit_tea_water'),
  Product(id: 'ftw_melon', name: 'Melon Fruit Tea', basePrice: 35.0, categoryId: 'fruit_tea_water'),
  Product(id: 'ftw_four_season', name: 'Four Season Fruit Tea', basePrice: 35.0, categoryId: 'fruit_tea_water'),

  // Cold Brew
  Product(id: 'cb_americano', name: 'Iced Americano', basePrice: 45.0, categoryId: 'cold_brew'),
  Product(id: 'cb_spanish', name: 'Iced Spanish Latte', basePrice: 45.0, categoryId: 'cold_brew'),
  Product(id: 'cb_mocha', name: 'Iced Mocha Latte', basePrice: 45.0, categoryId: 'cold_brew'),
  Product(id: 'cb_cappuccino', name: 'Iced Cappuccino Latte', basePrice: 45.0, categoryId: 'cold_brew'),
  Product(id: 'cb_white_mocha', name: 'Iced White Mocha', basePrice: 45.0, categoryId: 'cold_brew'),
  Product(id: 'cb_caramel_macchiato', name: 'Iced Caramel Macchiato', basePrice: 45.0, categoryId: 'cold_brew'),

  // Hot Brew
  Product(id: 'hb_americano', name: 'Hot Americano', basePrice: 45.0, categoryId: 'hot_brew'),
  Product(id: 'hb_spanish', name: 'Hot Spanish Latte', basePrice: 45.0, categoryId: 'hot_brew'),
  Product(id: 'hb_mocha', name: 'Hot Mocha Latte', basePrice: 45.0, categoryId: 'hot_brew'),
  Product(id: 'hb_cappuccino', name: 'Hot Cappuccino Latte', basePrice: 45.0, categoryId: 'hot_brew'),
  Product(id: 'hb_white_mocha', name: 'Hot White Mocha', basePrice: 45.0, categoryId: 'hot_brew'),
  Product(id: 'hb_caramel_macchiato', name: 'Hot Caramel Macchiato', basePrice: 45.0, categoryId: 'hot_brew'),

  // Premium Frappe
  Product(id: 'pf_mango_graham', name: 'Mango Graham Premium', basePrice: 55.0, categoryId: 'premium_frappe'),
  Product(id: 'pf_cookies_cream', name: 'Cookies & Cream Premium', basePrice: 65.0, categoryId: 'premium_frappe'),

  // Frappe (Coffee-Based)
  Product(id: 'fc_dark_caramel', name: 'Dark Caramel Frappe', basePrice: 45.0, categoryId: 'frappe_coffee'),
  Product(id: 'fc_dark_mocha', name: 'Dark Mocha Frappe', basePrice: 45.0, categoryId: 'frappe_coffee'),
  Product(id: 'fc_java_chip', name: 'Java Chip Frappe', basePrice: 45.0, categoryId: 'frappe_coffee'),

  // Frappe (Non-Coffee)
  Product(id: 'fnc_matcha', name: 'Matcha Frappe', basePrice: 45.0, categoryId: 'frappe_non_coffee'),
  Product(id: 'fnc_taro', name: 'Taro Frappe', basePrice: 45.0, categoryId: 'frappe_non_coffee'),
  Product(id: 'fnc_mango', name: 'Mango Frappe', basePrice: 45.0, categoryId: 'frappe_non_coffee'),
  Product(id: 'fnc_avocado', name: 'Avocado Frappe', basePrice: 45.0, categoryId: 'frappe_non_coffee'),
  Product(id: 'fnc_red_velvet', name: 'Red Velvet Frappe', basePrice: 45.0, categoryId: 'frappe_non_coffee'),
  Product(id: 'fnc_green_apple', name: 'Green Apple Frappe', basePrice: 45.0, categoryId: 'frappe_non_coffee'),

  // Fries
  Product(id: 'fr_bbq', name: 'BBQ Fries', basePrice: 30.0, categoryId: 'fries'),
  Product(id: 'fr_cheese', name: 'Cheese Fries', basePrice: 30.0, categoryId: 'fries'),
  Product(id: 'fr_sour_cream', name: 'Sour & Cream Fries', basePrice: 30.0, categoryId: 'fries'),
];

List<ModifierGroup> getModifierGroupsForProduct(Product product) {
  if (product.categoryId == 'fries') {
    return [
      ModifierGroup(
        id: 'fries_size',
        productId: product.id,
        name: 'Size Selection',
        isRequired: true,
        options: [
          ModifierOption(id: 'sz_small', groupId: 'fries_size', name: 'Small', priceDelta: 0.0, isDefault: true),
          ModifierOption(id: 'sz_medium', groupId: 'fries_size', name: 'Medium', priceDelta: 30.0),
          ModifierOption(id: 'sz_large', groupId: 'fries_size', name: 'Large', priceDelta: 60.0),
          ModifierOption(id: 'sz_xlarge', groupId: 'fries_size', name: 'X-Large', priceDelta: 90.0),
        ],
      )
    ];
  }

  // Premium Frappe sizes have specialized custom steps
  if (product.id == 'pf_mango_graham') {
    return [
      ModifierGroup(
        id: 'pf_mg_size',
        productId: product.id,
        name: 'Size Selection',
        isRequired: true,
        options: [
          ModifierOption(id: 'sz_medium', groupId: 'pf_mg_size', name: 'Medium', priceDelta: 0.0, isDefault: true),
          ModifierOption(id: 'sz_large', groupId: 'pf_mg_size', name: 'Large', priceDelta: 30.0),
        ],
      )
    ];
  }

  if (product.id == 'pf_cookies_cream') {
    return [
      ModifierGroup(
        id: 'pf_cc_size',
        productId: product.id,
        name: 'Size Selection',
        isRequired: true,
        options: [
          ModifierOption(id: 'sz_medium', groupId: 'pf_cc_size', name: 'Medium', priceDelta: 0.0, isDefault: true),
          ModifierOption(id: 'sz_large', groupId: 'pf_cc_size', name: 'Large', priceDelta: 20.0),
        ],
      )
    ];
  }

  // Standard beverages sizes and customization
  List<ModifierOption> sizeOptions = [
    ModifierOption(id: 'sz_med', groupId: 'size', name: 'Medium', priceDelta: 0.0, isDefault: true),
    ModifierOption(id: 'sz_lrg', groupId: 'size', name: 'Large', priceDelta: 10.0),
  ];

  if (product.categoryId == 'milk_tea' || product.categoryId == 'cheesecake' || product.categoryId.startsWith('fruit_tea')) {
    sizeOptions.add(ModifierOption(id: 'sz_liter', groupId: 'size', name: '1 Liter', priceDelta: 40.0));
  }

  return [
    ModifierGroup(
      id: 'size',
      productId: product.id,
      name: 'Size Selection',
      isRequired: true,
      options: sizeOptions,
    ),
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
