# Design Spec: POS-5890U-L Bluetooth Receipt Printer Integration

## Overview
Integrate the POS-5890U-L thermal printer into the VEEBREW Flutter POS app via Bluetooth. Provide a manual "Print Receipt" trigger after a successful checkout.

## Architecture

### 1. `PrinterService` (`lib/services/printer_service.dart`)
- **Library**: `blue_thermal_printer`
- **Responsibilities**:
  - Scanning for Bluetooth devices.
  - Connecting/Disconnecting to the printer.
  - Sending ESC/POS byte streams.
  - Tracking connection state via Riverpod.

### 2. `ReceiptGenerator` (`lib/services/receipt_generator.dart`)
- **Responsibilities**:
  - Building the receipt layout (Header, Items List, Totals, Footer).
  - Formatting for 58mm (32 characters per line).
  - Handling character encoding for currency symbols (₱).

### 3. UI Integration
- **Manual Print Trigger**: Add a "Print Receipt" button to the `CheckoutModal` success state or as a follow-up action.

## Implementation Details

### Dependencies
```yaml
blue_thermal_printer: ^1.2.3
```

### Receipt Format (58mm)
- **Header**: VEEBREW (Center, Bold, Double Size)
- **Order Info**: Order #, Date/Time
- **Items**: `Qty Name Price` (e.g., `1 Latte 120.00`)
- **Modifiers**: Indented under parent item.
- **Totals**: Subtotal, Discount, Total Amount.
- **Footer**: "Thank you for brewing with us!"

### State Management
- `printerProvider`: Manages the `blue_thermal_printer` instance and connection status.

## Success Criteria
1. User can scan and select POS-5890U-L in a settings/setup screen.
2. Connection persists during the session.
3. Tapping "Print" generates a correctly formatted 58mm receipt.
4. Handles "Out of Paper" or "Disconnected" errors gracefully.
