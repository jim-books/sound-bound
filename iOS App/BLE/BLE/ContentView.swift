import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @ObservedObject var bleManager = BLEManager()
    
    var body: some View {
        NavigationView {
            VStack {
                if bleManager.isConnected, let connectedPeripheral = bleManager.connectedPeripheral {
                    VStack {
                        Text("Connected to:")
                            .font(.headline)
                        Text(connectedPeripheral.name ?? "Unnamed Device")
                            .font(.title)
                            .padding()
                        
                        Button(action: {
                            bleManager.disconnect()
                        }) {
                            Text("Disconnect")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                } else {
                    VStack {
                        Text("Nearby BLE Devices")
                            .font(.headline)
                            .padding(.top)
                        
                        if bleManager.isScanning {
                            Text("Scanning...")
                                .foregroundColor(.gray)
                                .padding(.bottom)
                        } else {
                            Text("Scan Stopped")
                                .foregroundColor(.gray)
                                .padding(.bottom)
                        }
                        
                        List(bleManager.peripherals) { discovered in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(discovered.peripheral.name ?? "Unnamed Device")
                                        .font(.headline)
                                    Text("RSSI: \(discovered.rssi)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Button(action: {
                                    bleManager.connect(discovered.peripheral)
                                }) {
                                    Text("Connect")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .navigationBarItems(trailing: Button(action: {
                        if bleManager.isScanning {
                            bleManager.stopScanning()
                        } else {
                            bleManager.startScanning()
                        }
                    }) {
                        Text(bleManager.isScanning ? "Stop" : "Scan")
                    })
                }
            }
            .navigationBarTitle("BLE Scanner", displayMode: .inline)
        }
        .onAppear {
            // Optionally, start scanning on appear
            bleManager.startScanning()
        }
    }
}
