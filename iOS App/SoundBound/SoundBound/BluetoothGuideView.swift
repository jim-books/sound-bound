//
//  BluetoothGuideView.swift
//  SoundBound
//
//  Created by jimbook on 12/12/2024.
//

import SwiftUI

struct BluetoothGuideView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var bleManager: BLEManager // Accessing BLEManager from the environment
    
    @State private var nameFilter: String = "" // State variable for the name filter
    
    var filteredPeripherals: [DiscoveredPeripheral] {
        // If nameFilter is empty, return all peripherals
        // Otherwise, filter peripherals whose names contain the filter string (case-insensitive)
        if nameFilter.trimmingCharacters(in: .whitespaces).isEmpty {
            return bleManager.peripherals
        } else {
            return bleManager.peripherals.filter {
                $0.peripheral.name?.range(of: nameFilter, options: .caseInsensitive) != nil
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color(red: 0.38, green: 0.17, blue: 0)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                
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
                            
                            // Name Filter TextField
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                TextField("Filter by name...", text: $nameFilter)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            .padding([.leading, .trailing, .top])
                            
                            if bleManager.isScanning {
                                Text("Scanning...")
                                    .foregroundColor(.gray)
                                    .padding(.bottom)
                            } else {
                                Text("Scan Stopped")
                                    .foregroundColor(.gray)
                                    .padding(.bottom)
                            }
                            
                            List(filteredPeripherals) { discovered in
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
                            .listStyle(PlainListStyle())
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
            }
            .navigationBarTitle("Connect BEAT-01", displayMode: .inline)
        }
        .onAppear {
            // Optionally, start scanning on appear
            bleManager.startScanning()
        }
    }
}

struct BluetoothGuideView_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothGuideView()
            .environmentObject(BLEManager())
    }
}
