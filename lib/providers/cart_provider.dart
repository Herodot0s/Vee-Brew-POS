import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_item.dart';
import '../models/product.dart';

class CartNotifier extends Notifier<List<OrderItem>> {
  @override
  List<OrderItem> build() {
    return [];
  }

  void addQuickTap(Product product) {
    state = [...state, OrderItem(product: product, selectedModifiers: [])];
  }

  void addConfiguredItem(OrderItem item) {
    state = [...state, item];
  }

  void clearCart() {
    state = [];
  }

  double get total {
    return state.fold(0, (sum, item) => sum + item.calculatedPrice);
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<OrderItem>>(() {
  return CartNotifier();
});
