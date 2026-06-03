import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class PrinterService {
  Future<List<BluetoothInfo>> getDevices() async {
    try {
      return await PrintBluetoothThermal.pairedBluetooths;
    } catch (e) {
      return [];
    }
  }

  Future<bool> connect(String address) async {
    try {
      return await PrintBluetoothThermal.connect(macPrinterAddress: address);
    } catch (e) {
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      return await PrintBluetoothThermal.disconnect;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isConnected() async {
    try {
      return await PrintBluetoothThermal.connectionStatus;
    } catch (e) {
      return false;
    }
  }
}
