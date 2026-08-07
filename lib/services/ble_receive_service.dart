// lib/services/ble_receive_service.dart
//
// Receiver half of BLE contact exchange — the flutter_blue_plus central.
// Scans for phones advertising ContactSphere's share service (the native
// peripheral in android/.../BleShareServer.kt), connects, and downloads the
// vCard with the chunked protocol in ble_protocol.dart. The sender half is
// ble_share_service.dart; the UI is screens/ble_receive_screen.dart.

import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:smart_contacts_dialer/services/ble_protocol.dart';

/// Thrown when a nearby sender was found but the download failed — the
/// message is user-facing (shown in a snackbar by the receive screen).
class BleReceiveException implements Exception {
  final String message;
  const BleReceiveException(this.message);

  @override
  String toString() => message;
}

class BleReceiveService {
  static final BleReceiveService _instance = BleReceiveService._internal();
  factory BleReceiveService() => _instance;
  BleReceiveService._internal();

  static final Guid _serviceGuid = Guid(BleProtocol.serviceUuid);
  static final Guid _sizeGuid = Guid(BleProtocol.sizeUuid);
  static final Guid _offsetGuid = Guid(BleProtocol.offsetUuid);
  static final Guid _dataGuid = Guid(BleProtocol.dataUuid);

  /// Whether the adapter is on right now (false when unknown/unsupported).
  Future<bool> isBluetoothOn() async {
    try {
      return await FlutterBluePlus.adapterState.first ==
          BluetoothAdapterState.on;
    } catch (_) {
      return false;
    }
  }

  /// Asks Android to enable Bluetooth (shows the system consent dialog).
  /// Returns whether the adapter ended up on.
  Future<bool> turnOn() async {
    try {
      await FlutterBluePlus.turnOn();
      return await FlutterBluePlus.adapterState
              .where((s) => s != BluetoothAdapterState.turningOn)
              .first ==
          BluetoothAdapterState.on;
    } catch (_) {
      return false;
    }
  }

  /// Live scan results, already filtered to ContactSphere senders (the scan
  /// itself filters on the share-service UUID).
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  /// Starts (or restarts) a scan for nearby senders. [timeout] keeps a
  /// forgotten screen from scanning forever; the screen offers a rescan.
  Future<void> startScan({
    Duration timeout = const Duration(minutes: 1),
  }) async {
    try {
      if (FlutterBluePlus.isScanningNow) await FlutterBluePlus.stopScan();
      await FlutterBluePlus.startScan(
        withServices: [_serviceGuid],
        timeout: timeout,
      );
    } catch (e) {
      throw const BleReceiveException('Could not start Bluetooth scanning');
    }
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {
      // Screen is closing; nothing useful to do with a stop failure.
    }
  }

  /// The sender's display name from [result]'s scan response (the contact
  /// name the peripheral advertises as service data), or null when absent.
  String? displayNameOf(ScanResult result) {
    final data = result.advertisementData.serviceData[_serviceGuid];
    if (data != null && data.isNotEmpty) {
      try {
        final name = utf8.decode(data, allowMalformed: true).trim();
        if (name.isNotEmpty) return name;
      } catch (_) {
        // Fall through to the advertised name.
      }
    }
    final adv = result.advertisementData.advName.trim();
    return adv.isEmpty ? null : adv;
  }

  /// Connects to [device] and downloads the advertised vCard text.
  /// [onProgress] reports (receivedBytes, totalBytes) per chunk — used by the
  /// receive screen for a determinate progress bar on whole-book transfers.
  /// Always disconnects before returning. Throws [BleReceiveException] with a
  /// user-facing message on any failure.
  Future<String> fetchVCard(
    BluetoothDevice device, {
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      // ContactSphere is personal/nonprofit software, which is what the
      // FlutterBluePlus license enum attests. connect() also negotiates
      // MTU 512 by default — fewer chunked-read round-trips.
      await device.connect(
        license: License.nonprofit,
        timeout: const Duration(seconds: 15),
      );
    } catch (_) {
      throw const BleReceiveException('Could not connect to the other phone');
    }
    try {
      final services = await device.discoverServices();
      final service = services.where((s) => s.uuid == _serviceGuid).firstOrNull;
      if (service == null) {
        throw const BleReceiveException(
          'The other phone stopped sharing — ask them to try again',
        );
      }
      final sizeChar = service.characteristics
          .where((c) => c.uuid == _sizeGuid)
          .firstOrNull;
      final offsetChar = service.characteristics
          .where((c) => c.uuid == _offsetGuid)
          .firstOrNull;
      final dataChar = service.characteristics
          .where((c) => c.uuid == _dataGuid)
          .firstOrNull;
      if (sizeChar == null || offsetChar == null || dataChar == null) {
        throw const BleReceiveException('Unrecognized sharing service');
      }

      final int size;
      try {
        size = BleProtocol.decodeUint32Le(await sizeChar.read());
      } on FormatException {
        throw const BleReceiveException('Could not read the contact');
      }

      final bytes = await BleProtocol.assembleChunks(
        size: size,
        onProgress: onProgress,
        readAt: (offset) async {
          await offsetChar.write(BleProtocol.encodeUint32Le(offset));
          return dataChar.read();
        },
      );
      return utf8.decode(bytes, allowMalformed: true);
    } on BleReceiveException {
      rethrow;
    } catch (_) {
      throw const BleReceiveException('The transfer failed — try again');
    } finally {
      try {
        await device.disconnect();
      } catch (_) {}
    }
  }
}
