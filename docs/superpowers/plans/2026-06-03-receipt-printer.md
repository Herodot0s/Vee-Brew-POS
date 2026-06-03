# POS-5890U-L Receipt Printer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Integrate POS-5890U-L Bluetooth thermal printer for manual receipt printing after checkout.

**Architecture:** Use `blue_thermal_printer` for Bluetooth comms and a dedicated `ReceiptGenerator` for ESC/POS formatting. Managed via Riverpod.

**Tech Stack:** Flutter, Riverpod, blue_thermal_printer.

---

### Task 1: Add Dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add blue_thermal_printer to pubspec.yaml**

```yaml
dependencies:
  blue_thermal_printer: ^1.2.3
```

- [ ] **Step 2: Run flutter pub get**

Run: `flutter pub get`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml
git commit -m "deps: add blue_thermal_printer"
```

---

### Task 2: Create Printer Service

**Files:**
- Create: `lib/services/printer_service.dart`

- [ ] **Step 1: Implement Bluetooth scanning and connection logic**

```dart
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PrinterService {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  Future<List<BluetoothDevice>> getDevices() async {
    return await bluetooth.getBondedDevices();
  }

  Future<void> connect(BluetoothDevice device) async {
    await bluetooth.connect(device);
  }

  Future<void> disconnect() async {
    await bluetooth.disconnect();
  }

  Future<bool?> isConnected() async {
    return await bluetooth.isConnected;
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/services/printer_service.dart
git commit -m "feat: add PrinterService for bluetooth management"
```

---

### Task 3: Create Receipt Generator

**Files:**
- Create: `lib/services/receipt_generator.dart`

- [ ] **Step 1: Implement ESC/POS formatting for 58mm**

```dart
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../models/cart_item.dart'; // Assume this exists

class ReceiptGenerator {
  static Future<void> generate(BlueThermalPrinter bt, String orderNumber, List<dynamic> items, double total) async {
    bt.write('\x1B\x61\x01'); // Center
    bt.write('\x1B\x21\x30'); // Double size
    bt.printCustom("VEEBREW", 3, 1);
    bt.write('\x1B\x21\x00'); // Reset size
    bt.printNewLine();
    bt.printLeftRight("Order:", orderNumber, 1);
    bt.printLeftRight("Date:", DateTime.now().toString().substring(0, 16), 1);
    bt.printCustom("--------------------------------", 1, 1);
    
    for (var item in items) {
      bt.printLeftRight("${item.product.name}", "P${item.calculatedPrice.toStringAsFixed(2)}", 1);
    }
    
    bt.printCustom("--------------------------------", 1, 1);
    bt.printLeftRight("TOTAL:", "P${total.toStringAsFixed(2)}", 2);
    bt.printNewLine();
    bt.printCustom("Thank you for brewing!", 1, 1);
    bt.printNewLine();
    bt.printNewLine();
    bt.paperCut();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/services/receipt_generator.dart
git commit -m "feat: add ReceiptGenerator for ESC/POS formatting"
```

---

### Task 4: UI Integration in CheckoutModal

**Files:**
- Modify: `lib/widgets/checkout_modal.dart`

- [ ] **Step 1: Add "Print Receipt" button to success state**

```dart
// Inside _handlePayment after success
if (mounted) {
  // Show print button or trigger print
  _showPrintOption(context, orderNumber);
}
```

- [ ] **Step 2: Implement printer selection dialog if not connected**

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/checkout_modal.dart
git commit -m "feat: integrate print trigger in CheckoutModal"
```
