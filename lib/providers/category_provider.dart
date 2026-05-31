import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'milk_tea';

  void setCategory(String categoryId) {
    state = categoryId;
  }
}

final selectedCategoryProvider = NotifierProvider<SelectedCategoryNotifier, String>(() {
  return SelectedCategoryNotifier();
});
