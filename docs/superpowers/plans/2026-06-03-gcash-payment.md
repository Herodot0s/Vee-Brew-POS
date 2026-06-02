# GCash Payment Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Integrate a "Show QR & Manual Confirm" GCash payment option into the POS checkout flow.

**Architecture:** We will update the `CheckoutModal` to include a GCash button. Selecting GCash transitions the modal to a `GCashPaymentView` which displays a static placeholder QR code and a required reference number input. We will update `checkoutServiceProvider.processCheckout` to accept 'GCash' and handle it similarly to existing methods.

**Tech Stack:** Flutter, Riverpod

---

### Task 1: Update Checkout Service to Support GCash

**Files:**
- Modify: `lib/providers/checkout_provider.dart`
- Test: `test/unit/providers/checkout_provider_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/unit/providers/checkout_provider_test.dart
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/providers/checkout_provider_test.dart`
Expected: FAIL (or PASS if it already blindly accepts any string, but we want to ensure it's explicitly handled or at least not rejected). *Assuming it needs explicit handling if there's validation.*

- [ ] **Step 3: Write minimal implementation**

*If `checkout_provider.dart` has explicit method validation:*
```dart
// Modify lib/providers/checkout_provider.dart
// Inside processCheckout(String method):
if (method != 'Cash' && method != 'Card' && method != 'GCash') {
  throw Exception('Unsupported payment method');
}
```
*(If it already accepts any string, just verify and move on)*

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/unit/providers/checkout_provider_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add test/unit/providers/checkout_provider_test.dart lib/providers/checkout_provider.dart
git commit -m "feat: add GCash payment method support to checkout service"
```

### Task 2: Create GCash Payment View Widget

**Files:**
- Create: `lib/widgets/checkout/gcash_payment_view.dart`
- Test: `test/widget/gcash_payment_view_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/widget/gcash_payment_view_test.dart
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

    expect(find.text('₱150.00'), findsOneWidget);
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widget/gcash_payment_view_test.dart`
Expected: FAIL (File not found)

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/widgets/checkout/gcash_payment_view.dart
import 'package:flutter/material.dart';
import '../../theme/binance_theme.dart';

class GCashPaymentView extends StatefulWidget {
  final double amountDue;
  final ValueChanged<String> onConfirm;
  final VoidCallback onCancel;

  const GCashPaymentView({
    super.key,
    required this.amountDue,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<GCashPaymentView> createState() => _GCashPaymentViewState();
}

class _GCashPaymentViewState extends State<GCashPaymentView> {
  final _refController = TextEditingController();

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'GCash Payment',
          style: BinanceTheme.titleStyle(size: 20, weight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: BinanceTheme.spaceLg),
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.qr_code_2, size: 100, color: Colors.black),
          ),
        ),
        const SizedBox(height: BinanceTheme.spaceMd),
        Text(
          'Amount Due: ₱${widget.amountDue.toStringAsFixed(2)}',
          style: BinanceTheme.numberStyle(size: 24, weight: FontWeight.bold, color: BinanceTheme.primary),
        ),
        const SizedBox(height: BinanceTheme.spaceLg),
        TextField(
          controller: _refController,
          style: const TextStyle(color: Colors.white),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Reference Number',
            labelStyle: const TextStyle(color: BinanceTheme.muted),
            filled: true,
            fillColor: BinanceTheme.surfaceElevatedDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: BinanceTheme.spaceXl),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: widget.onCancel,
              child: const Text('Cancel', style: TextStyle(color: BinanceTheme.muted)),
            ),
            const SizedBox(width: BinanceTheme.spaceMd),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: BinanceTheme.primary,
                foregroundColor: Colors.black,
              ),
              onPressed: _refController.text.trim().isEmpty
                  ? null
                  : () => widget.onConfirm(_refController.text.trim()),
              child: const Text('Confirm Payment'),
            ),
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widget/gcash_payment_view_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/checkout/gcash_payment_view.dart test/widget/gcash_payment_view_test.dart
git commit -m "feat: create GCash payment view widget with validation"
```

### Task 3: Integrate GCash View into CheckoutModal

**Files:**
- Modify: `lib/widgets/checkout_modal.dart`
- Test: `test/widget/checkout_modal_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/widget/checkout_modal_test.dart (Add/Update this test)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veebrew/widgets/checkout_modal.dart';

void main() {
  testWidgets('CheckoutModal shows GCash button and transitions to GCash view', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: CheckoutModal()),
        ),
      ),
    );

    expect(find.text('GCASH'), findsOneWidget);
    
    // Tap GCash
    await tester.tap(find.text('GCASH'));
    await tester.pumpAndSettle();

    // Should show GCash payment view
    expect(find.text('Reference Number'), findsOneWidget);
    expect(find.text('GCASH'), findsNothing); // Original buttons hidden
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widget/checkout_modal_test.dart`
Expected: FAIL (Cannot find GCASH text)

- [ ] **Step 3: Write minimal implementation**

Modify `lib/widgets/checkout_modal.dart`:
1. Add `enum CheckoutStep { methodSelection, gcashVerification }`
2. Add state variable `CheckoutStep _step = CheckoutStep.methodSelection;`
3. Add GCASH `_PaymentButton` next to CASH and CARD.
4. When GCASH is tapped, `setState(() => _step = CheckoutStep.gcashVerification);`
5. In `build`, if `_step == CheckoutStep.gcashVerification`, return the `GCashPaymentView` instead of the method selection buttons.
6. Pass `_handlePayment('GCash')` to `onConfirm` and `setState(() => _step = CheckoutStep.methodSelection)` to `onCancel`.

```dart
// lib/widgets/checkout_modal.dart modifications
import 'checkout/gcash_payment_view.dart';

enum CheckoutStep { methodSelection, gcashVerification }

class _CheckoutModalState extends ConsumerState<CheckoutModal> {
  bool _isProcessing = false;
  CheckoutStep _step = CheckoutStep.methodSelection;
  
  // ... existing code ...

  Widget _buildMethodSelection(double total, int cartLength) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ... existing header, amount due ...
        Row(
          children: [
            Expanded(child: _PaymentButton(label: 'CASH', icon: Icons.payments_outlined, onTap: () => _handlePayment('Cash'))),
            const SizedBox(width: BinanceTheme.spaceMd),
            Expanded(child: _PaymentButton(label: 'CARD', icon: Icons.credit_card_outlined, onTap: () => _handlePayment('Card'))),
            const SizedBox(width: BinanceTheme.spaceMd),
            Expanded(
              child: _PaymentButton(
                label: 'GCASH',
                icon: Icons.qr_code_scanner,
                onTap: () => setState(() => _step = CheckoutStep.gcashVerification),
              ),
            ),
          ],
        ),
        // ... cancel button ...
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = ref.watch(cartTotalProvider);
    final cart = ref.watch(cartProvider);

    return Dialog(
      // ...
      child: Container(
        // ...
        child: _step == CheckoutStep.gcashVerification
            ? GCashPaymentView(
                amountDue: total,
                onConfirm: (refNumber) => _handlePayment('GCash'),
                onCancel: () => setState(() => _step = CheckoutStep.methodSelection),
              )
            : _buildMethodSelection(total, cart.length),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widget/checkout_modal_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/checkout_modal.dart test/widget/checkout_modal_test.dart
git commit -m "feat: integrate GCash verification view into checkout modal"
```
