import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_item.dart';
import '../models/product.dart';
import '../models/modifier.dart';

class CartNotifier extends Notifier<List<OrderItem>> {
  OrderItem? _lastDeletedItem;
  int? _lastDeletedIndex;

  @override
  List<OrderItem> build() {
    return [];
  }

  void addQuickTap(Product product) {
    state = [
      ...state,
      OrderItem(product: product, selectedModifiers: const <ModifierOption>[]),
    ];
  }

  void addConfiguredItem(OrderItem item) {
    state = [...state, item];
  }

  void updateConfiguredItem(int index, OrderItem item) {
    if (index >= 0 && index < state.length) {
      state = [
        ...state.sublist(0, index),
        item,
        ...state.sublist(index + 1),
      ];
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < state.length) {
      _lastDeletedItem = state[index];
      _lastDeletedIndex = index;
      state = [
        ...state.sublist(0, index),
        ...state.sublist(index + 1),
      ];
    }
  }

  void undoDelete() {
    if (_lastDeletedItem != null && _lastDeletedIndex != null) {
      final index = _lastDeletedIndex!;
      final item = _lastDeletedItem!;
      _lastDeletedItem = null;
      _lastDeletedIndex = null;
      
      if (index >= 0 && index <= state.length) {
        state = [
          ...state.sublist(0, index),
          item,
          ...state.sublist(index),
        ];
      } else {
        state = [...state, item];
      }
    }
  }

  bool get canUndo => _lastDeletedItem != null;

  void clearCart() {
    state = [];
    _lastDeletedItem = null;
    _lastDeletedIndex = null;
  }

  double get total {
    return state.fold(0, (sum, item) => sum + item.calculatedPrice);
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<OrderItem>>(() {
  return CartNotifier();
});
