import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:veebrew/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: VeebrewApp()));

    // Verify that the POSScreen with VEEBREW sidebar title is shown.
    expect(find.text('VEEBREW'), findsOneWidget);
  });
}
