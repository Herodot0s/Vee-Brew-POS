import 'package:flutter_test/flutter_test.dart';
import 'package:veebrew/services/receipt_generator.dart';
import 'package:veebrew/models/order_item.dart';
import 'package:veebrew/models/product.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ReceiptGenerator generates bytes without store address and has split date/order', () async {
    final items = [
      const OrderItem(
        product: Product(
          id: 'mt_wintermelon',
          name: 'Wintermelon Milk Tea',
          basePrice: 28.0,
          categoryId: 'milk_tea',
        ),
        selectedModifiers: [],
      ),
    ];

    final bytes = await ReceiptGenerator.generateBytes('VEE-1001', items, 28.0);
    final receiptText = String.fromCharCodes(bytes);

    // Verify address lines are removed
    expect(receiptText.contains('Nueva Ecija Street'), isFalse);
    expect(receiptText.contains('Magsaysay Bago bantay'), isFalse);

    // Verify social media is kept
    expect(receiptText.contains('FB Page: veebrew'), isTrue);

    // Verify date and order number are on separate lines (i.e. not justified together on one line)
    expect(receiptText.contains('DATE:'), isTrue);
    expect(receiptText.contains('ORDER NO:'), isTrue);
    // Confirms date and order no do not appear on the same line
    final lines = receiptText.split('\n');
    final hasCombinedLine = lines.any((l) => l.contains('DATE:') && l.contains('ORDER NO:'));
    expect(hasCombinedLine, isFalse, reason: 'Date and Order No should be on separate lines');
  });
}
