import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veebrew/providers/category_provider.dart';

void main() {
  test('selectedCategoryProvider default and update', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(selectedCategoryProvider), 'milk_tea');

    container.read(selectedCategoryProvider.notifier).setCategory('cheesecake');
    expect(container.read(selectedCategoryProvider), 'cheesecake');
  });
}
