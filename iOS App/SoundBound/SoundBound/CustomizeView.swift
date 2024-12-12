//
//  CustomizeView.swift
//  SoundBound
//
//  Created by jimbook on 12/12/2024.
//

import SwiftUI

struct CustomizeView: View {
    @State private var showEditSheet = false
    @State private var selectedPreset: String = "preset1" // Placeholder for preset identifier
    
    var body: some View {
        NavigationView {
            ZStack{
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color(red: 0.38, green: 0.17, blue: 0)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Placeholder Image for Current Preset
                    Image(systemName: "pianokeys")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding()
                    
                    Spacer()
                    
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
}


#Preview {
    CustomizeView()
}
