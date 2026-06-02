import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veebrew/models/product.dart';
import 'package:veebrew/models/order_item.dart';
import 'package:veebrew/providers/cart_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('Cart starts empty', () {
    final cart = container.read(cartProvider);
    expect(cart, isEmpty);
  });

  test('addQuickTap adds a product with no modifiers', () {
    const product = Product(
      id: '1',
      name: 'Test Tea',
      basePrice: 5.0,
      categoryId: '1',
    );

    container.read(cartProvider.notifier).addQuickTap(product);
    final cart = container.read(cartProvider);

    expect(cart.length, 1);
    expect(cart.first.product.name, 'Test Tea');
    expect(cart.first.selectedModifiers, isEmpty);
  });

  test('addConfiguredItem adds an item with modifiers', () {
    const product = Product(
      id: '1',
      name: 'Test Tea',
      basePrice: 5.0,
      categoryId: '1',
    );

    const item = OrderItem(
      product: product,
      selectedModifiers: [], // Mocking for now
    );

    container.read(cartProvider.notifier).addConfiguredItem(item);
    final cart = container.read(cartProvider);

    expect(cart.length, 1);
    expect(cart.first.product.name, 'Test Tea');
  });

  test('removeItem removes item by index', () {
    const product1 = Product(
      id: '1',
      name: 'Test Tea 1',
      basePrice: 5.0,
      categoryId: '1',
    );
    const product2 = Product(
      id: '2',
      name: 'Test Tea 2',
      basePrice: 10.0,
      categoryId: '1',
    );

    final notifier = container.read(cartProvider.notifier);
    notifier.addQuickTap(product1);
    notifier.addQuickTap(product2);

    expect(container.read(cartProvider).length, 2);

    notifier.removeItem(0);
    final cart = container.read(cartProvider);

    expect(cart.length, 1);
    expect(cart.first.product.name, 'Test Tea 2');
  });

  test('clearCart empties the cart', () {
    const product = Product(
      id: '1',
      name: 'Test Tea',
      basePrice: 5.0,
      categoryId: '1',
    );

    container.read(cartProvider.notifier).addQuickTap(product);
    expect(container.read(cartProvider).length, 1);

    container.read(cartProvider.notifier).clearCart();
    expect(container.read(cartProvider), isEmpty);
  });

  test('total calculates correctly', () {
    const product1 = Product(
      id: '1',
      name: 'Test Tea 1',
      basePrice: 5.0,
      categoryId: '1',
    );

    const product2 = Product(
      id: '2',
      name: 'Test Tea 2',
      basePrice: 3.5,
      categoryId: '1',
    );

    container.read(cartProvider.notifier).addQuickTap(product1);
    container.read(cartProvider.notifier).addQuickTap(product2);

    expect(container.read(cartProvider.notifier).total, 8.5);
  });

  test('updateConfiguredItem updates item at correct index', () {
    const product1 = Product(
      id: '1',
      name: 'Test Tea 1',
      basePrice: 5.0,
      categoryId: '1',
    );
    const product2 = Product(
      id: '2',
      name: 'Test Tea 2',
      basePrice: 10.0,
      categoryId: '1',
    );

    final notifier = container.read(cartProvider.notifier);
    notifier.addQuickTap(product1);

    expect(container.read(cartProvider)[0].product.name, 'Test Tea 1');

    notifier.updateConfiguredItem(0, const OrderItem(product: product2, selectedModifiers: []));
    expect(container.read(cartProvider)[0].product.name, 'Test Tea 2');
  });

  test('removeItem and undoDelete recovers deleted item', () {
    const product = Product(
      id: '1',
      name: 'Test Tea 1',
      basePrice: 5.0,
      categoryId: '1',
    );

    final notifier = container.read(cartProvider.notifier);
    notifier.addQuickTap(product);

    expect(notifier.canUndo, isFalse);

    notifier.removeItem(0);
    expect(container.read(cartProvider), isEmpty);
    expect(notifier.canUndo, isTrue);

    notifier.undoDelete();
    expect(container.read(cartProvider).length, 1);
    expect(container.read(cartProvider)[0].product.name, 'Test Tea 1');
    expect(notifier.canUndo, isFalse);
  });
}
