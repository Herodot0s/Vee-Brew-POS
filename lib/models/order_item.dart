import 'product.dart';
import 'modifier.dart';

class OrderItem {
  final Product product;
  final List<ModifierOption> selectedModifiers;

  const OrderItem({required this.product, required this.selectedModifiers});

  double get calculatedPrice {
    double total = product.basePrice;
    for (var mod in selectedModifiers) {
      total += mod.priceDelta;
    }
    return total;
  }
}
