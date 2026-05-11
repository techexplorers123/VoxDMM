import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEService {
  static const String deviceName = "Bluetooth DMM";

  static final Guid notifyUuid = Guid("0000fff4-0000-1000-8000-00805f9b34fb");

  BluetoothDevice? _device;

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothConnectionState>? _connectionSub;
  StreamSubscription<List<int>>? _notifySub;

  final StreamController<Uint8List> _dataController =
      StreamController.broadcast();

  Stream<Uint8List> get dataStream => _dataController.stream;

  bool get isConnected => _device?.isConnected == true;

  Future<void> start() async {
    await _waitForBluetooth();

    await _scanAndConnect();
  }

  Future<void> _waitForBluetooth() async {
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      throw Exception("Bluetooth is off");
    }
  }

  Future<void> _scanAndConnect() async {
    await FlutterBluePlus.stopScan();

    _scanSub?.cancel();

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    _scanSub = FlutterBluePlus.scanResults.listen((results) async {
      for (final result in results) {
        final device = result.device;

        if (device.platformName != deviceName) continue;

        await FlutterBluePlus.stopScan();

        _device = device;

        await _connect();

        break;
      }
    });
  }

  Future<void> _connect() async {
    if (_device == null) return;

    try {
      await _device!.connect(
        license: License.free,
        timeout: const Duration(seconds: 15),
      );
    } catch (_) {
      // already connected
    }

    _connectionSub?.cancel();

    _connectionSub = _device!.connectionState.listen((state) async {
      if (state == BluetoothConnectionState.disconnected) {
        await cleanup();
      }
    });

    final services = await _device!.discoverServices();

    for (final service in services) {
      for (final characteristic in service.characteristics) {
        if (characteristic.uuid != notifyUuid) continue;

        await characteristic.setNotifyValue(true);

        _notifySub?.cancel();

        _notifySub = characteristic.onValueReceived.listen((value) {
          _dataController.add(Uint8List.fromList(value));
        });

        return;
      }
    }

    throw Exception("Notify characteristic not found");
  }

  Future<void> disconnect() async {
    await _device?.disconnect();
  }

  Future<void> cleanup() async {
    await _scanSub?.cancel();
    await _connectionSub?.cancel();
    await _notifySub?.cancel();
  }

  Future<void> dispose() async {
    await cleanup();
    await disconnect();
    await _dataController.close();
  }
}
