import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEService {
  static const String deviceName = "Bluetooth DMM";
  bool _reconnecting = false;
  bool _disposed = false;
  static final Guid notifyUuid = Guid("0000fff4-0000-1000-8000-00805f9b34fb");
  final StreamController<String> _statusController =
      StreamController.broadcast();
  Stream<String> get statusStream => _statusController.stream;
  BluetoothDevice? _device;

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothConnectionState>? _connectionSub;
  StreamSubscription<List<int>>? _notifySub;

  final StreamController<Uint8List> _dataController =
      StreamController.broadcast();

  Stream<Uint8List> get dataStream => _dataController.stream;

  bool get isConnected => _device?.isConnected == true;

  void _emitStatus(String status) {
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  void _emitData(List<int> value) {
    if (!_dataController.isClosed) {
      _dataController.add(Uint8List.fromList(value));
    }
  }

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
    _emitStatus("Scanning");
    _scanSub = FlutterBluePlus.scanResults.listen((results) async {
      for (final result in results) {
        final device = result.device;

        if (device.platformName != deviceName) continue;
        await FlutterBluePlus.stopScan();

        _device = device;
        _emitStatus("Connecting");
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
    } catch (_) {}
    _connectionSub?.cancel();
    _emitStatus("Connected");
    _connectionSub = _device!.connectionState.listen((state) async {
      if (state == BluetoothConnectionState.disconnected) {
        await _cleanupNotifications();
        _emitStatus("Disconnected");
        await _tryReconnect();
      }
    });

    await _setupNotifications();
  }

  Future<void> _cleanupNotifications() async {
    await _notifySub?.cancel();
    _notifySub = null;
  }

  Future<void> _setupNotifications() async {
    final services = await _device!.discoverServices();

    for (final service in services) {
      for (final characteristic in service.characteristics) {
        if (characteristic.uuid != notifyUuid) {
          continue;
        }

        await characteristic.setNotifyValue(true);

        await _notifySub?.cancel();

        _notifySub = characteristic.onValueReceived.listen((value) {
          _emitData(value);
        });

        return;
      }
    }

    throw Exception("Notify characteristic not found");
  }

  Future<void> _tryReconnect() async {
    if (_reconnecting || _disposed || _device == null) {
      return;
    }

    _reconnecting = true;
    _emitStatus("Reconnecting");
    while (!_disposed) {
      try {
        await _device!.connect(
          license: License.free,
          timeout: const Duration(seconds: 15),
        );
        await _setupNotifications();
        _emitStatus("Connected");
        break;
      } catch (_) {
        await Future.delayed(const Duration(seconds: 3));
      }
    }

    _reconnecting = false;
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
    _disposed = true;

    await cleanup();

    await disconnect();
    await _dataController.close();
    await _statusController.close();
  }
}
