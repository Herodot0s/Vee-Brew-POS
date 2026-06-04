import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../models/order_item.dart';
import '../models/modifier.dart';

class ReceiptGenerator {
  static String _formatDateTime(DateTime dt) {
    final year = dt.year;
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    
    final hour24 = dt.hour;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final amPm = hour24 >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    final hourStr = hour12.toString().padLeft(2, '0');

    return "$day/$month/$year $hourStr:$minute $amPm";
  }

  static String justify(String left, String right, {int width = 32}) {
    final available = width - left.length - right.length;
    if (available <= 0) {
      final maxLeftLen = width - right.length - 1;
      if (maxLeftLen > 3) {
        return left.substring(0, maxLeftLen - 3) + '...' + ' ' + right;
      }
      return left.substring(0, maxLeftLen.clamp(0, left.length)) + ' ' + right;
    }
    return left + (' ' * available) + right;
  }

  static Future<List<int>> generateBytes(
    String orderNumber,
    List<OrderItem> items,
    double total, {
    String paymentMethod = 'GCash',
    double? amountReceived,
    double? changeAmount,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];
    
    const int width = 32; // Default 58mm printer width

    // Header border
    bytes += generator.text('=' * width, styles: const PosStyles(align: PosAlign.center));

    // Centered brand title (Veebrew size as is)
    bytes += generator.text("VEEBREW",
        styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
            bold: true));

    // Store details
    bytes += generator.text("15 Nueva Ecija Street, Barangay Ramon",
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text("Magsaysay Bago bantay QC",
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text("FB Page: veebrew",
        styles: const PosStyles(align: PosAlign.center));
    
    // Header bottom border
    bytes += generator.text('=' * width, styles: const PosStyles(align: PosAlign.center));

    // Date and Order Number
    final dateStr = "DATE: ${_formatDateTime(DateTime.now())}";
    final orderStr = "ORDER NO: $orderNumber";
    bytes += generator.text(justify(dateStr, orderStr, width: width),
        styles: const PosStyles(align: PosAlign.left));

    // Inner divider
    bytes += generator.text('-' * width, styles: const PosStyles(align: PosAlign.center));

    double subtotal = 0.0;

    for (var item in items) {
      // Find size modifier if any
      ModifierOption? sizeMod;
      for (var mod in item.selectedModifiers) {
        final name = mod.name.toLowerCase();
        if (mod.id.contains('sz_') ||
            name == 'small' ||
            name == 'medium' ||
            name == 'large' ||
            name == '1 liter' ||
            name == 'jumbo') {
          sizeMod = mod;
          break;
        }
      }

      // Calculate item base price (product base price + size price delta)
      double itemBasePrice = item.product.basePrice;
      String productTitle = item.product.name;
      if (sizeMod != null) {
        itemBasePrice += sizeMod.priceDelta;
        productTitle = "${item.product.name} (${sizeMod.name})";
      }

      subtotal += itemBasePrice;

      // Print main item row
      final leftItem = "1x $productTitle";
      final rightItem = itemBasePrice.toStringAsFixed(2);
      bytes += generator.text(justify(leftItem, rightItem, width: width),
          styles: const PosStyles(align: PosAlign.left));

      // Print non-size modifiers
      for (var mod in item.selectedModifiers) {
        if (mod == sizeMod) continue; // Skip size modifier as it's printed inline

        subtotal += mod.priceDelta;

        if (mod.priceDelta == 0.0) {
          bytes += generator.text("   + ${mod.name}",
              styles: const PosStyles(align: PosAlign.left));
        } else {
          final leftMod = "   + ${mod.name}";
          final rightMod = mod.priceDelta.toStringAsFixed(2);
          bytes += generator.text(justify(leftMod, rightMod, width: width),
              styles: const PosStyles(align: PosAlign.left));
        }
      }
      bytes += generator.feed(1); // Space between items
    }

    bytes += generator.text('-' * width, styles: const PosStyles(align: PosAlign.center));

    // Subtotal and Total
    bytes += generator.text(justify("SUBTOTAL:", subtotal.toStringAsFixed(2), width: width),
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text(justify("TOTAL:", total.toStringAsFixed(2), width: width),
        styles: const PosStyles(align: PosAlign.left));

    bytes += generator.feed(1);

    // Payment details
    bytes += generator.text("PAYMENT METHOD: ${paymentMethod.toUpperCase()}",
        styles: const PosStyles(align: PosAlign.left));

    if (paymentMethod.toLowerCase() == 'cash' && amountReceived != null && changeAmount != null) {
      bytes += generator.text(justify("AMOUNT RECEIVED:", amountReceived.toStringAsFixed(2), width: width),
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text(justify("CHANGE:", changeAmount.toStringAsFixed(2), width: width),
          styles: const PosStyles(align: PosAlign.left));
    }

    bytes += generator.text('-' * width, styles: const PosStyles(align: PosAlign.center));

    // Centered Footer
    bytes += generator.text("Thank you for craving Veebrew!",
        styles: const PosStyles(align: PosAlign.center));

    bytes += generator.text('=' * width, styles: const PosStyles(align: PosAlign.center));

    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }
}
