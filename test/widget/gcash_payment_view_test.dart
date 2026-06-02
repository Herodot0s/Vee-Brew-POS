import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veebrew/widgets/checkout/gcash_payment_view.dart';

void main() {
  testWidgets('GCashPaymentView shows amount, QR placeholder, input, and buttons', (tester) async {
    bool confirmed = false;
    bool canceled = false;
    String ref = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GCashPaymentView(
            amountDue: 150.0,
            onConfirm: (val) {
              confirmed = true;
              ref = val;
            },
            onCancel: () => canceled = true,
          ),
        ),
      ),
    );

    expect(find.text('Amount Due: ₱150.00'), findsOneWidget);
    expect(find.text('Reference Number'), findsOneWidget);

    // Confirm should be disabled initially
    final confirmBtn = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Confirm Payment'));
    expect(confirmBtn.onPressed, isNull);

    // Enter reference
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();

    // Confirm should be enabled
    final confirmBtnEnabled = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Confirm Payment'));
    expect(confirmBtnEnabled.onPressed, isNotNull);

    await tester.tap(find.text('Confirm Payment'));
    expect(confirmed, isTrue);
    expect(ref, '123456');
  });
}
