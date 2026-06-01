import 'package:flutter_test/flutter_test.dart';
import 'package:veebrew/models/mock_data.dart';

void main() {
  test('mock data parses successfully', () {
    expect(mockCategories.length, 10);
    expect(mockProducts.length, 50);

    final milkTeas = mockProducts
        .where((p) => p.categoryId == 'milk_tea')
        .toList();
    expect(milkTeas.length, 8);

    final fries = mockProducts.firstWhere((p) => p.id == 'fr_bbq');
    final friesGroups = getModifierGroupsForProduct(fries);
    expect(friesGroups.length, 1);
    expect(friesGroups.first.options.length, 4);
  });
}
