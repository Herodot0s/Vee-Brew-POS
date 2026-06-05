# Customer Name on Receipt and POS Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Allow entering an optional customer name during POS checkout, persist it in the database, display it on the printed receipt (if provided), and show it in the Admin order history.

**Architecture:** Add a new nullable `customerName` column to the `Orders` database table using Drift, increment schema version, update `ReceiptGenerator` and checkout service to handle the parameter, and add input/display elements in the POS/Admin screens.

**Tech Stack:** Flutter, Riverpod, Drift (SQLite), esc_pos_utils_plus

---

## File Structure & Responsibilities

1. `lib/database/drift_database.dart`: Database table schema and migration logic.
2. `lib/providers/checkout_provider.dart`: Checkout service capturing and storing the customer name.
3. `lib/services/receipt_generator.dart`: Byte generation for the thermal receipt printer.
4. `lib/widgets/checkout_modal.dart`: Dialog capturing the customer name and payment details.
5. `lib/screens/admin_dashboard_screen.dart`: UI listing historical orders and details.

---

### Task 1: Database Schema update & Migration

**Files:**
- Modify: `lib/database/drift_database.dart`
- Modify: `test/admin_test.dart`

- [x] **Step 1: Update the database table and migration path**
  Modify `lib/database/drift_database.dart` to add the `customerName` column to `Orders`, increment `schemaVersion` to `5`, and add the migration step to the `onUpgrade` strategy.

  *Modified `lib/database/drift_database.dart`:*
  ```dart
  class Orders extends Table {
    IntColumn get id => integer().autoIncrement()();
    TextColumn get orderNumber => text()();
    RealColumn get totalAmount => real()();
    TextColumn get paymentMethod => text()();
    DateTimeColumn get createdAt => dateTime()();
    BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
    RealColumn get amountReceived => real().nullable()();
    RealColumn get changeAmount => real().nullable()();
    TextColumn get customerName => text().nullable()(); // Added
  }
  ```

  And:
  ```dart
  @override
  int get schemaVersion => 5; // Updated from 4

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(orders, orders.isSynced);
      }
      if (from < 3) {
        await m.deleteTable('modifiers');
        await m.createTable(modifiers);
      }
      if (from < 4) {
        await m.addColumn(orders, orders.amountReceived);
        await m.addColumn(orders, orders.changeAmount);
      }
      if (from < 5) {
        await m.addColumn(orders, orders.customerName); // Added migration
      }
    },
  );
  ```

- [x] **Step 2: Regenerate drift database code**
  Run: `flutter pub run build_runner build --delete-conflicting-outputs`
  Expected: Successful code generation, creating updated types (like `customerName` field in `Order` and `OrdersCompanion`).

- [x] **Step 3: Add unit test to verify database migration**
  Open `test/admin_test.dart` and add a test case to verify writing/reading the new `customerName` field:

  ```dart
  test('Database customer name persistence', () async {
    final id = await db.into(db.orders).insert(
      OrdersCompanion.insert(
        orderNumber: '20260605-999',
        totalAmount: 150.0,
        paymentMethod: 'Cash',
        createdAt: DateTime.now(),
        customerName: const Value('Juan Dela Cruz'),
      ),
    );

    final order = await (db.select(db.orders)..where((t) => t.id.equals(id))).getSingle();
    expect(order.customerName, 'Juan Dela Cruz');
  });
  ```

- [x] **Step 4: Run unit tests to verify database changes**
  Run: `flutter test test/admin_test.dart`
  Expected: PASS

- [x] **Step 5: Commit changes**
  Run: `git add lib/database/drift_database.dart lib/database/drift_database.g.dart test/admin_test.dart`
  Run: `git commit -m "feat(db): add customerName to orders table and migration"`

---

### Task 2: Receipt Generator Updates

**Files:**
- Modify: `lib/services/receipt_generator.dart`
- Modify: `test/unit/receipt_generator_test.dart`

- [x] **Step 1: Update `generateBytes` method signature and formatting**
  Modify `lib/services/receipt_generator.dart` to accept an optional `customerName` string. If present and not empty, format and append `CUSTOMER: <name>` below `ORDER NO`.

  *Modified `lib/services/receipt_generator.dart`:*
  ```dart
  static Future<List<int>> generateBytes(
    String orderNumber,
    List<OrderItem> items,
    double total, {
    String paymentMethod = 'GCash',
    double? amountReceived,
    double? changeAmount,
    String? customerName, // Added parameter
  }) async {
  ```

  And inside `generateBytes`:
  ```dart
    // Date and Order Number
    bytes += generator.text("DATE: ${_formatDateTime(DateTime.now())}",
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text("ORDER NO: $orderNumber",
        styles: const PosStyles(align: PosAlign.left));

    if (customerName != null && customerName.trim().isNotEmpty) {
      bytes += generator.text("CUSTOMER: ${customerName.trim().toUpperCase()}",
          styles: const PosStyles(align: PosAlign.left));
    }
  ```

- [x] **Step 2: Add tests for receipt customer name**
  Add unit tests in `test/unit/receipt_generator_test.dart` to verify customer name line behavior.

  *Added tests in `test/unit/receipt_generator_test.dart`:*
  ```dart
  test('ReceiptGenerator includes customer name when provided', () async {
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

    final bytes = await ReceiptGenerator.generateBytes(
      'VEE-1001',
      items,
      28.0,
      customerName: 'Juan Dela Cruz',
    );
    final receiptText = String.fromCharCodes(bytes);

    expect(receiptText.contains('CUSTOMER: JUAN DELA CRUZ'), isTrue);
  });

  test('ReceiptGenerator omits customer name line when not provided or empty', () async {
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

    final bytes = await ReceiptGenerator.generateBytes(
      'VEE-1001',
      items,
      28.0,
      customerName: '',
    );
    final receiptText = String.fromCharCodes(bytes);

    expect(receiptText.contains('CUSTOMER:'), isFalse);
  });
  ```

- [x] **Step 3: Run receipt generator tests**
  Run: `flutter test test/unit/receipt_generator_test.dart`
  Expected: PASS

- [x] **Step 4: Commit changes**
  Run: `git add lib/services/receipt_generator.dart test/unit/receipt_generator_test.dart`
  Run: `git commit -m "feat(receipt): add customer name formatting to printed receipts"`

---

### Task 3: Checkout Service Update

**Files:**
- Modify: `lib/providers/checkout_provider.dart`
- Modify: `test/unit/providers/checkout_provider_test.dart`

- [x] **Step 1: Modify `processCheckout` signature and implementation**
  Update `lib/providers/checkout_provider.dart` to accept an optional `customerName` parameter and insert it in the database.

  *Modified `lib/providers/checkout_provider.dart`:*
  ```dart
  Future<String> processCheckout(
    String paymentMethod, {
    double? amountReceived,
    double? changeAmount,
    String? customerName, // Added parameter
  }) async {
  ```

  And inside the `insert` companion mapping:
  ```dart
      // Insert order
      final orderId = await db
          .into(db.orders)
          .insert(
            OrdersCompanion.insert(
              orderNumber: on,
              totalAmount: total,
              paymentMethod: paymentMethod,
              createdAt: now,
              isSynced: const Value(false),
              amountReceived: Value(amountReceived),
              changeAmount: Value(changeAmount),
              customerName: Value(customerName), // Added
            ),
          );
  ```

- [x] **Step 2: Add test verifying customer name is saved by CheckoutService**
  Add a test case in `test/unit/providers/checkout_provider_test.dart` to assert customer name is saved correctly.

  *Added test in `test/unit/providers/checkout_provider_test.dart`:*
  ```dart
  test('CheckoutService saves optional customer name', () async {
    final db = AppDatabase.memory();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
    );

    final cartNotifier = container.read(cartProvider.notifier);
    cartNotifier.addConfiguredItem(
      const OrderItem(
        product: Product(id: 'prod1', name: 'Coffee', basePrice: 100.0, categoryId: 'cat1'),
        selectedModifiers: [],
      ),
    );

    final service = container.read(checkoutServiceProvider);
    final orderNum = await service.processCheckout('GCash', customerName: 'Alice');

    final order = await (db.select(db.orders)..where((t) => t.orderNumber.equals(orderNum))).getSingle();
    expect(order.customerName, 'Alice');

    await db.close();
  });
  ```

- [x] **Step 3: Run checkout provider tests**
  Run: `flutter test test/unit/providers/checkout_provider_test.dart`
  Expected: PASS

- [x] **Step 4: Commit changes**
  Run: `git add lib/providers/checkout_provider.dart test/unit/providers/checkout_provider_test.dart`
  Run: `git commit -m "feat(checkout): support saving customer name in CheckoutService"`

---

### Task 4: POS Checkout UI

**Files:**
- Modify: `lib/widgets/checkout_modal.dart`

- [x] **Step 1: Add text editing controller and field**
  Modify `lib/widgets/checkout_modal.dart` to define a `_customerNameController`, dispose it properly, and show a `TextField` inside `_buildMethodSelection` before selecting the payment method.

  *Modified state declaration:*
  ```dart
  class _CheckoutModalState extends ConsumerState<CheckoutModal> {
    bool _isProcessing = false;
    CheckoutStep _step = CheckoutStep.methodSelection;
    final _printerService = PrinterService();
    final _cashController = TextEditingController();
    final _customerNameController = TextEditingController(); // Added
  ```

  *Modified dispose:*
  ```dart
  @override
  void dispose() {
    _cashController.dispose();
    _customerNameController.dispose(); // Added
    super.dispose();
  }
  ```

- [x] **Step 2: Update `_handlePayment` call signature**
  Modify `_handlePayment` to extract the trimmed customer name, pass it to `processCheckout`, and then pass it to the print methods:

  *Modified `_handlePayment`:*
  ```dart
  Future<void> _handlePayment(String method, {double? amountReceived, double? changeAmount}) async {
    setState(() => _isProcessing = true);

    try {
      final cartSnapshot = ref.read(cartProvider);
      final total = ref.read(cartTotalProvider);
      final customerName = _customerNameController.text.trim(); // Added
      final orderNumber =
          await ref.read(checkoutServiceProvider).processCheckout(
            method,
            amountReceived: amountReceived,
            changeAmount: changeAmount,
            customerName: customerName.isNotEmpty ? customerName : null, // Added
          );

      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment Successful — $orderNumber',
            style: BinanceTheme.titleStyle(color: Colors.white),
          ),
          backgroundColor: BinanceTheme.tradingUp,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      _showPrintOption(
        context,
        orderNumber,
        cartSnapshot,
        total,
        method,
        amountReceived,
        changeAmount,
        customerName.isNotEmpty ? customerName : null, // Added
      );
    } on Exception catch (e) {
  ```

- [x] **Step 3: Update `_showPrintOption` and `_showPrinterSelection` signatures & arguments**
  Update both methods to receive and forward `String? customerName` to `ReceiptGenerator.generateBytes`.

  *Modified `_showPrintOption` signature & print callback:*
  ```dart
  void _showPrintOption(
    BuildContext context,
    String orderNumber,
    List<OrderItem> items,
    double total,
    String paymentMethod,
    double? amountReceived,
    double? changeAmount,
    String? customerName, // Added
  ) {
  ```
  And inside print button `onPressed`:
  ```dart
  final bytes = await ReceiptGenerator.generateBytes(
    orderNumber,
    items,
    total,
    paymentMethod: paymentMethod,
    amountReceived: amountReceived,
    changeAmount: changeAmount,
    customerName: customerName, // Added
  );
  ```

  *Modified `_showPrinterSelection` signature & print callback:*
  ```dart
  void _showPrinterSelection(
    BuildContext context,
    String orderNumber,
    List<OrderItem> items,
    double total,
    String paymentMethod,
    double? amountReceived,
    double? changeAmount,
    String? customerName, // Added
  ) async {
  ```
  And inside printer select callback:
  ```dart
  final bytes = await ReceiptGenerator.generateBytes(
    orderNumber,
    items,
    total,
    paymentMethod: paymentMethod,
    amountReceived: amountReceived,
    changeAmount: changeAmount,
    customerName: customerName, // Added
  );
  ```

  *Ensure calls to `_showPrinterSelection` pass the customer name parameter:*
  ```dart
  _showPrinterSelection(
    context,
    orderNumber,
    items,
    total,
    paymentMethod,
    amountReceived,
    changeAmount,
    customerName, // Added
  );
  ```

- [x] **Step 4: Embed input field in `_buildMethodSelection`**
  Insert the text field right above the payment button row in `_buildMethodSelection`.

  *Modified `_buildMethodSelection` layout:*
  ```dart
  Widget _buildMethodSelection(double total, int cartLength) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Checkout',
              style: BinanceTheme.titleStyle(
                size: 20,
                weight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '${cartLength} item${cartLength == 1 ? '' : 's'}',
              style: BinanceTheme.titleStyle(color: BinanceTheme.muted),
            ),
          ],
        ),
        const SizedBox(height: BinanceTheme.spaceLg),
        Container(height: 1, color: BinanceTheme.surfaceElevatedDark),
        const SizedBox(height: BinanceTheme.spaceLg),
        Text(
          'Amount Due',
          style: BinanceTheme.titleStyle(color: BinanceTheme.muted),
        ),
        const SizedBox(height: BinanceTheme.spaceXs),
        Text(
          '₱${total.toStringAsFixed(2)}',
          style: BinanceTheme.numberStyle(
            size: 48,
            weight: FontWeight.bold,
            color: BinanceTheme.primary,
          ),
        ),
        const SizedBox(height: BinanceTheme.spaceLg),
        // Customer Name input field
        TextField(
          controller: _customerNameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Customer Name (Optional)',
            labelStyle: const TextStyle(color: BinanceTheme.muted),
            filled: true,
            fillColor: BinanceTheme.surfaceElevatedDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: BinanceTheme.primary),
            ),
          ),
        ),
        const SizedBox(height: BinanceTheme.spaceXl),
        if (_isProcessing)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: BinanceTheme.spaceLg),
            child: CircularProgressIndicator(color: BinanceTheme.primary),
          )
        else
          Row(
            children: [
              Expanded(
                child: _PaymentButton(
                  label: 'CASH',
                  icon: Icons.payments_outlined,
                  onTap: () => setState(() => _step = CheckoutStep.cashPayment),
                ),
              ),
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
        const SizedBox(height: BinanceTheme.spaceLg),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _isProcessing
                ? null
                : () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: BinanceTheme.titleStyle(color: BinanceTheme.muted),
            ),
          ),
        ),
      ],
    );
  }
  ```

- [x] **Step 5: Commit UI changes**
  Run: `git add lib/widgets/checkout_modal.dart`
  Run: `git commit -m "feat(ui): add customer name input field to checkout dialog"`

---

### Task 5: Admin Dashboard Order History

**Files:**
- Modify: `lib/screens/admin_dashboard_screen.dart`

- [x] **Step 1: Display customer name in Order History list details**
  Modify the `_OrderHistoryView` list view inside `lib/screens/admin_dashboard_screen.dart` to show a styled Row indicating the customer's name when present.

  *Modified `_OrderHistoryView` in `lib/screens/admin_dashboard_screen.dart` (around line 124):*
  ```dart
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(BinanceTheme.spaceMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (order.customerName != null && order.customerName!.trim().isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 16, color: BinanceTheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'Customer: ${order.customerName}',
                                  style: const TextStyle(
                                    color: BinanceTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
  ```

- [x] **Step 2: Commit admin dashboard changes**
  Run: `git add lib/screens/admin_dashboard_screen.dart`
  Run: `git commit -m "feat(ui): display customer name in Admin order history"`
