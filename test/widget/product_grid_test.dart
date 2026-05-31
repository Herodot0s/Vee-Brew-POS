import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veebrew/widgets/product_grid.dart';

void main() {
  testWidgets('ProductGrid filters products by category', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ProductGrid(),
          ),
        ),
      ),
    );

    // Initial default category is 'milk_tea'
    expect(find.text('Wintermelon Milk Tea'), findsOneWidget);
    expect(find.text('Okinawa Milk Tea'), findsOneWidget);
    expect(find.text('BBQ Fries'), findsNothing);
  });
}
