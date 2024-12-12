//
//  CustomizeView.swift
//  SoundBound
//
//  Created by jimbook on 12/12/2024.
//

import SwiftUI

// MARK: - DrumPart Struct

/// Represents a part of the drum kit with its properties.
struct DrumPart: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    /// Position offsets relative to the drum kit's center
    let offset: CGPoint
    /// Volume level (0.0 to 1.0)
    var volume: Double
    /// Scale level (0.5 to 2.0) - Fixed after initialization
    let scale: Double
    /// Selection state
    var isSelected: Bool
}

// MARK: - CustomizeView

struct CustomizeView: View {
    @State private var showEditSheet = false
    @State private var selectedPreset: String = "preset1" // Placeholder for preset identifier
    
    // Initialize drum parts with their positions and fixed scales
    @State private var drumParts: [DrumPart] = [
        DrumPart(name: "Snare",
                 imageName: "snare",
                 offset: CGPoint(x: -75, y: 10),
                 volume: 0.5,
                 scale: 1.55,
                 isSelected: false),
        DrumPart(name: "Hi-Hat",
                 imageName: "hihat",
                 offset: CGPoint(x: -155, y: 35),
                 volume: 0.5,
                 scale: 1.45,
                 isSelected: false),
        DrumPart(name: "Tom 1",
                 imageName: "midtom",
                 offset: CGPoint(x: 35, y: -55),
                 volume: 0.5,
                 scale: 1.4,
                 isSelected: false),
        DrumPart(name: "Tom 2",
                 imageName: "hightom",
                 offset: CGPoint(x: -45, y: -50),
                 volume: 0.5,
                 scale: 1.45,
                 isSelected: false),
        DrumPart(name: "Tom 3",
                 imageName: "floortom",
                 offset: CGPoint(x: 75, y: -5),
                 volume: 0.5,
                 scale: 1.5,
                 isSelected: false),
        DrumPart(name: "Cymbal",
                 imageName: "cymbal",
                 offset: CGPoint(x: -133, y: -50),
                 volume: 0.5,
                 scale: 2.3,
                 isSelected: false),
        DrumPart(name: "Ride",
                imageName: "ride",
                offset: CGPoint(x: 140, y: -45),
                volume: 0.5,
                 scale: 2.3,
                isSelected: false)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color(red: 0.38, green: 0.17, blue: 0)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Drum Kit Container
                    ZStack {
                        // Base Drum Kit Image (Optional)
                        Image("drumkit") // Ensure you have an image named "drumkit" in your assets
                            .resizable()
                            .scaledToFit()
                            .frame(width: 400, height: 400)
                        
                        // Overlay Drum Parts
                        ForEach($drumParts) { $part in
                            ZStack {
                                // Drum Part Image
                                Image(part.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    // Apply fixed scale by adjusting the frame size
                                    .frame(width: 60 * CGFloat(part.scale), height: 60 * CGFloat(part.scale))
                                    .offset(x: part.offset.x, y: part.offset.y)
                                    // Highlight if selected
                                    .shadow(color: part.isSelected ? Color.orange : Color.clear, radius: 8)
                                    .opacity(part.isSelected ? 1 : 0.001)
                                    .onTapGesture {
                                        toggleSelection(for: part)
                                    }
                                
                                // Volume Slider for Selected Part
                                if part.isSelected {
                                    VStack {
                                        // Volume Slider
                                        VStack {
                                            Text("Volume")
                                                .foregroundColor(.white)
                                                .font(.caption)
                                            Slider(value: $drumParts[getIndex(of: part)].volume, in: 0...1)
                                                .accentColor(.orange)
                                        }
                                        .frame(width: 120)
                                        .padding(.bottom, 5)
                                        .background(Color.black.opacity(0.5))
                                        .cornerRadius(8)
                                        .offset(x: part.offset.x + 100, y: part.offset.y)
                                        
                                        // Volume Label
                                        Text(String(format: "%.0f%%", drumParts[getIndex(of: part)].volume * 100))
                                            .foregroundColor(.white)
                                            .font(.caption)
                                            .offset(x: part.offset.x + 100, y: part.offset.y + 20)
                                    }
                                    .transition(.opacity)
                                    .animation(.easeInOut, value: part.isSelected)
                                }
                            }
                        }
                    }
                    .frame(width: 300, height: 300)
                    .padding()
                    
                    Spacer()
                    
                    // Edit Preset Button
                    NavigationLink(destination: EditPresetView(selectedPreset: $selectedPreset)) {
                        Circle()
                            .fill(Color.black.opacity(0.7))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "pencil")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            )
                            .shadow(color: Color.orange, radius: 8)
                    }
                    .padding(.bottom, 40)
                    .accessibilityLabel("Edit Drum Preset")
                }
                .padding(.bottom, 80)
                .navigationTitle("Customize")
                .sheet(isPresented: $showEditSheet) {
                    EditPresetView(selectedPreset: $selectedPreset)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    /// Toggles the selection state of a drum part.
    /// Ensures that only one drum part is selected at a time.
    private func toggleSelection(for part: DrumPart) {
        // Determine if the tapped part is already selected
        let isAlreadySelected = part.isSelected
        
        // Iterate through all drum parts and update their selection states
        for index in drumParts.indices {
            if drumParts[index].id == part.id {
                drumParts[index].isSelected = !isAlreadySelected
            } else {
                drumParts[index].isSelected = false
            }
        }
    }
    
    /// Retrieves the index of a given drum part.
    private func getIndex(of part: DrumPart) -> Int {
        drumParts.firstIndex(where: { $0.id == part.id }) ?? 0
    }
}

// MARK: - Preview

struct CustomizeView_Previews: PreviewProvider {
    static var previews: some View {
        CustomizeView()
    }
}
