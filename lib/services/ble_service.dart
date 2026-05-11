import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEService {
  static const String deviceName = "Bluetooth DMM";

  static const String dmmUUID = "0000fff4-0000-1000-8000-00805f9b34fb";

  BluetoothDevice? device;

  BluetoothCharacteristic? notifyChar;

  Future<void> startScan({required Function(Uint8List data) onData}) async {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        final d = r.device;

        if (d.platformName == deviceName) {
          await FlutterBluePlus.stopScan();

          device = d;

          await connect(onData: onData);

          break;
        }
      }
    });
  }

  Future<void> connect({required Function(Uint8List data) onData}) async {
    if (device == null) return;

    await device!.connect(license: License.free);

    final services = await device!.discoverServices();

    for (BluetoothService service in services) {
      for (BluetoothCharacteristic c in service.characteristics) {
        if (c.uuid.toString().toLowerCase() == dmmUUID) {
          notifyChar = c;

          await c.setNotifyValue(true);

          c.lastValueStream.listen((value) {
            onData(Uint8List.fromList(value));
          });

          return;
        }
      }
    }
  }

  Future<void> disconnect() async {
    await device?.disconnect();
  }
}
