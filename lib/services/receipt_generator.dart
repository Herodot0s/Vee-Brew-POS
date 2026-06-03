import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../models/order_item.dart';

class ReceiptGenerator {
  static Future<void> generate(BlueThermalPrinter bt, String orderNumber, List<OrderItem> items, double total) async {
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
