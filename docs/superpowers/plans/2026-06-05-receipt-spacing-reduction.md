# Receipt Spacing Reduction Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove all explicit line feeds (`generator.feed`) from the receipt layout to compress vertical space.

**Architecture:** Edit `lib/services/receipt_generator.dart` to remove item-level, total-level, and end-of-receipt vertical feeds. Update `test/unit/receipt_generator_test.dart` to verify that no `feed` byte sequences (ESC d n, i.e., `[27, 100, n]`) are produced.

**Tech Stack:** Dart, Flutter Test, esc_pos_utils_plus

---

### Task 1: Spacing Reduction and Spacing Unit Tests

**Files:**
- Modify: `lib/services/receipt_generator.dart`
- Modify: `test/unit/receipt_generator_test.dart`

- [ ] **Step 1: Write the failing test**

Open `test/unit/receipt_generator_test.dart` and add a test verifying that the output bytes do not contain the ESC/POS feed command (`[27, 100, n]`).

```dart
  test('ReceiptGenerator does not contain explicit feed commands', () async {
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

    // ESC/POS feed command is ESC d n (27, 100, n)
    bool hasFeedCommand = false;
    for (int i = 0; i < bytes.length - 2; i++) {
      if (bytes[i] == 27 && bytes[i + 1] == 100) {
        hasFeedCommand = true;
        break;
      }
    }

    expect(hasFeedCommand, isFalse, reason: 'Should not contain ESC/POS feed (27, 100) commands');
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/receipt_generator_test.dart`
Expected: FAIL (finding a feed command sequence)

- [ ] **Step 3: Implement minimal code changes**

Modify `lib/services/receipt_generator.dart` to remove all three `generator.feed` calls:
1. Line 122 (remove `bytes += generator.feed(1);`)
2. Line 133 (remove `bytes += generator.feed(1);`)
3. Line 154 (remove `bytes += generator.feed(2);`)

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/unit/receipt_generator_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/services/receipt_generator.dart test/unit/receipt_generator_test.dart
git commit -m "feat: eliminate all explicit vertical feed lines from receipts"
```
