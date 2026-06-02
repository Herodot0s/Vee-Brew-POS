import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veebrew/providers/checkout_provider.dart';

void main() {
  test('CheckoutService supports GCash method', () async {
    final container = ProviderContainer();
    final service = container.read(checkoutServiceProvider);

    // Should not throw an unsupported method exception
    expect(
      () => service.processCheckout('GCash'),
      returnsNormally,
    );
  });
}
