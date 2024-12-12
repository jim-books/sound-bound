//
//  BLE.swift
//  SoundBound
//
//  Created by jimbook on 13/12/2024.
//

import Foundation
import CoreBluetooth
import Combine

class BLEManager: NSObject, ObservableObject {
    // Published properties to update the UI
    @Published var peripherals: [DiscoveredPeripheral] = []
    @Published var isScanning: Bool = false
    @Published var connectedPeripheral: CBPeripheral?
    @Published var isConnected: Bool = false
    @Published var nameFilter: String = "" // New Published Property
    @Published var isFilterEnabled: Bool = false // Optional: Toggle for Filter

    private var centralManager: CBCentralManager!

    // Replace with your ESP32's service UUID
    let esp32ServiceUUID = CBUUID(string: "03B80E5A-EDE8-4B33-A751-6CE34EC4C700")

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }

    // Start scanning for peripherals
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            print("Bluetooth is not powered on.")
            return
        }
        peripherals.removeAll()
        isScanning = true
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        print("Started scanning for peripherals with service UUID: \(esp32ServiceUUID)")
    }

    // Stop scanning
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
        print("Stopped scanning.")
    }

    // Connect to a peripheral
    func connect(_ peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }

    // Disconnect from a peripheral
    func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }

    // Method to update the filter and refresh the scan
    func updateFilter(to name: String, enabled: Bool) {
        self.nameFilter = name
        self.isFilterEnabled = enabled
        // Optionally, restart scanning to apply the new filter immediately
        if isScanning {
            stopScanning()
            startScanning()
        }
    }
}

// MARK: - CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("Central state is .unknown")
        case .resetting:
            print("Central state is .resetting")
        case .unsupported:
            print("Central state is .unsupported")
        case .unauthorized:
            print("Central state is .unauthorized")
        case .poweredOff:
            print("Central state is .poweredOff")
        case .poweredOn:
            print("Central state is .poweredOn")
            startScanning()
        @unknown default:
            print("Central state is unknown")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        // Apply name filtering if enabled
        if isFilterEnabled, let deviceName = peripheral.name {
            // Case-insensitive comparison
            let matches = deviceName.lowercased().contains(nameFilter.lowercased())
            if !matches {
                // Skip this peripheral as it doesn't match the filter
                return
            }
        }

        let discoveredPeripheral = DiscoveredPeripheral(peripheral: peripheral, rssi: RSSI)

        // Avoid duplicates
        if !peripherals.contains(where: { $0.peripheral.identifier == peripheral.identifier }) {
            peripherals.append(discoveredPeripheral)
            print("Discovered: \(peripheral.name ?? "Unnamed") at RSSI: \(RSSI)")
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unnamed device")")
        connectedPeripheral = peripheral
        isConnected = true
        stopScanning()

        // Example: Discover services
        peripheral.delegate = self
        peripheral.discoverServices([esp32ServiceUUID])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "Unnamed device"): \(error?.localizedDescription ?? "No error")")
        isConnected = false
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.name ?? "Unnamed device")")
        isConnected = false
        connectedPeripheral = nil
        startScanning() // Optionally, restart scanning
    }
}

// MARK: - CBPeripheralDelegate
extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }

        guard let services = peripheral.services else { return }
        for service in services {
            print("Discovered service: \(service.uuid)")
            // Discover characteristics if needed
        }
    }

    // Implement additional delegate methods as required
}

// MARK: - DiscoveredPeripheral Model
struct DiscoveredPeripheral: Identifiable {
    let id = UUID()
    let peripheral: CBPeripheral
    let rssi: NSNumber
}
