//
//  BluetoothGuideView.swift
//  SoundBound
//
//  Created by jimbook on 12/12/2024.
//

import SwiftUI

struct BluetoothGuideView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var bleManager = BLEManager()
    @State private var filterText: String = ""
    @State private var filterEnabled: Bool = false

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
                        // Filter Section
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Filter by Name:")
                                    .font(.headline)
                                Spacer()
                                Toggle(isOn: $filterEnabled) {
                                    Text("")
                                }
                                .labelsHidden()
                            }

                            TextField("Enter device name or prefix", text: $filterText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(!filterEnabled)
                                .onChange(of: filterText) { newValue in
                                    bleManager.updateFilter(to: newValue, enabled: filterEnabled)
                                }

                            // If you prefer to apply the filter on toggle change instead of text change:
                            /*
                            Toggle(isOn: $filterEnabled) {
                                Text("Enable Name Filter")
                            }
                            .onChange(of: filterEnabled) { newValue in
                                bleManager.updateFilter(to: filterText, enabled: newValue)
                            }

                            TextField("Enter device name or prefix", text: $filterText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(!filterEnabled)
                                .onSubmit {
                                    bleManager.updateFilter(to: filterText, enabled: filterEnabled)
                                }
                            */
                        }
                        .padding([.horizontal, .top])

                        // Device List Section
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
                                            .foregroundColor(discovered.peripheral.name?.starts(with: "ESP32") ?? false ? .green : .primary)
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

#Preview {
    BluetoothGuideView()
}
