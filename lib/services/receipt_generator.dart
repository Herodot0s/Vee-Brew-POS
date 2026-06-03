import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../models/order_item.dart';

class ReceiptGenerator {
  static Future<List<int>> generateBytes(
      String orderNumber, List<OrderItem> items, double total) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    bytes += generator.text("VEEBREW",
        styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
            bold: true));
    bytes += generator.feed(1);
    bytes += generator.text("Order: $orderNumber",
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text(
        "Date: ${DateTime.now().toString().substring(0, 16)}",
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.hr();

    for (var item in items) {
      bytes += generator.row([
        PosColumn(text: "1x ${item.product.name}", width: 9),
        PosColumn(
            text: "P${item.calculatedPrice.toStringAsFixed(2)}",
            width: 3,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
      if (item.selectedModifiers.isNotEmpty) {
        for (var mod in item.selectedModifiers) {
          bytes += generator.text("  + ${mod.name}",
              styles: const PosStyles(align: PosAlign.left));
        }
      }
    }

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: "TOTAL:", width: 8, styles: const PosStyles(bold: true)),
      PosColumn(
          text: "P${total.toStringAsFixed(2)}",
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.feed(1);
    bytes += generator.text("Thank you for brewing!",
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }
}
