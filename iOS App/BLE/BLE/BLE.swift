import Foundation
import CoreBluetooth
import Combine

class BLEManager: NSObject, ObservableObject {
    // Published properties to update the UI
    @Published var peripherals: [DiscoveredPeripheral] = []
    @Published var isScanning: Bool = false
    @Published var connectedPeripheral: CBPeripheral?
    @Published var isConnected: Bool = false
    
    private var centralManager: CBCentralManager!
    
    // Specify your ESP32's service UUID to filter devices (replace with your actual UUID)
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
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
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
        // Further configuration can be done here, e.g., discovering services
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

// MARK: - DiscoveredPeripheral Model
struct DiscoveredPeripheral: Identifiable {
    let id = UUID()
    let peripheral: CBPeripheral
    let rssi: NSNumber
}
