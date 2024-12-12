//
//  EditPresetView.swift
//  SoundBound
//
//  Created by jimbook on 12/12/2024.
//

import SwiftUI

struct EditPresetView: View {
    @Binding var selectedPreset: String
    @State private var showHandSelection = false
    
    // Example Preset Options
    let presets = ["Classic", "Jazz", "Rock", "Electronic", "Latin", "HipHop"]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(presets, id: \.self) { preset in
                    Button(action: {
                        selectedPreset = preset
                    }) {
                        VStack {
                            Image(systemName: "square.grid.2x2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .padding()
                            Text(preset)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .background(selectedPreset == preset ? Color.orange.opacity(0.2) : Color.orange.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
            
            // Hand Selection Button
            Button(action: {
                showHandSelection.toggle()
            }) {
                HStack {
                    Image(systemName: "hand.raised.fingers.spread")
                    Text("Select Handedness")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.orange)
                .cornerRadius(10)
                .shadow(radius: 4)
            }
            .padding()
            .sheet(isPresented: $showHandSelection) {
                HandSelectionView()
            }
        }
        .navigationTitle("Select Preset")
    }
}


//#Preview {
//    EditPresetView()
//}
