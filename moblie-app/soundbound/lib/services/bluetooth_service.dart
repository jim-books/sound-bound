import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/drum_config.dart';

class BluetoothService with ChangeNotifier {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _notifyCharacteristic;
  
  bool _isScanning = false;
  bool _isConnected = false;
  Stream<List<int>>? _midiDataStream;
  
  final String _serviceUuid = '03B80E5A-EDE8-4B33-A751-6CE34EC4C700'; // Example UUID
  final String _writeCharUuid = '7772E5DB-3868-4112-A1A9-F2669D106BF3';
  final String _notifyCharUuid = '36F6D2EB-2F4B-4A6B-AAE2-9D2F06142A6E';
  
  // Getters
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  Stream<List<int>>? get midiDataStream => _midiDataStream;
  
  // Start scanning for devices
  Future<void> startScan() async {
    try {
      _isScanning = true;
      notifyListeners();
      
      // Start scanning
      await flutterBlue.startScan(timeout: const Duration(seconds: 15));
      
      // Listen to scan results
      flutterBlue.scanResults.listen((results) {
        // Process scan results
        notifyListeners();
      });
      
      // When scanning is done
      flutterBlue.isScanning.listen((isScanning) {
        _isScanning = isScanning;
        notifyListeners();
      });
    } catch (e) {
      _isScanning = false;
      notifyListeners();
      debugPrint('Error during scanning: $e');
    }
  }
  
  // Stop scanning
  Future<void> stopScan() async {
    try {
      await flutterBlue.stopScan();
    } catch (e) {
      debugPrint('Error stopping scan: $e');
    }
  }
  
  // Connect to device
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;
      _isConnected = true;
      notifyListeners();
      
      // Discover services
      await _discoverServiceAndCharacteristics();
      
      return true;
    } catch (e) {
      _isConnected = false;
      notifyListeners();
      debugPrint('Error connecting to device: $e');
      return false;
    }
  }
  
  // Disconnect from device
  Future<void> disconnect() async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        _connectedDevice = null;
        _writeCharacteristic = null;
        _notifyCharacteristic = null;
        _isConnected = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error disconnecting from device: $e');
    }
  }
  
  // Discover services and characteristics
  Future<void> _discoverServiceAndCharacteristics() async {
    if (_connectedDevice == null) return;
    
    try {
      List<BluetoothService> services = await _connectedDevice!.discoverServices();
      
      for (BluetoothService service in services) {
        if (service.uuid.toString() == _serviceUuid) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == _writeCharUuid) {
              _writeCharacteristic = characteristic;
            } else if (characteristic.uuid.toString() == _notifyCharUuid) {
              _notifyCharacteristic = characteristic;
              await characteristic.setNotifyValue(true);
              _midiDataStream = characteristic.value;
              notifyListeners();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error discovering services: $e');
    }
  }
  
  // Send sitting height configuration
  Future<bool> sendSittingHeight(double height) async {
    if (!_isConnected || _writeCharacteristic == null) return false;
    
    try {
      final Map<String, dynamic> data = {
        'command_type': 'sitting_height',
        'payload': {'height': height}
      };
      
      final encodedData = utf8.encode(json.encode(data));
      await _writeCharacteristic!.write(encodedData);
      return true;
    } catch (e) {
      debugPrint('Error sending sitting height: $e');
      return false;
    }
  }
  
  // Send drum configuration
  Future<bool> sendDrumConfig(List<DrumElement> drumElements) async {
    if (!_isConnected || _writeCharacteristic == null) return false;
    
    try {
      final List<Map<String, dynamic>> drumData = drumElements
          .map((drum) => {
                'id': drum.id,
                'name': drum.name,
                'volume': drum.volume,
                'sound_filter': drum.soundFilter,
                'position': {
                  'x': drum.position.dx,
                  'y': drum.position.dy,
                }
              })
          .toList();
      
      final Map<String, dynamic> data = {
        'command_type': 'drum_config',
        'payload': {'drums': drumData}
      };
      
      final encodedData = utf8.encode(json.encode(data));
      await _writeCharacteristic!.write(encodedData);
      return true;
    } catch (e) {
      debugPrint('Error sending drum configuration: $e');
      return false;
    }
  }
}
