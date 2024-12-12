import SwiftUI

// Step 1: Define the Preset struct
struct Preset: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
}

struct EditPresetView: View {
    @Binding var selectedPreset: String
    @State private var showHandSelection = false
    
    // Step 2: Update the presets array with designated images
    let presets: [Preset] = [
        Preset(name: "Classic", imageName: "pianokeys.inverse"),
        Preset(name: "Jazz", imageName: "music.quarternote.3"),
        Preset(name: "Rock", imageName: "guitars"),
        Preset(name: "Electronic", imageName: "waveform.path"),
        Preset(name: "Latin", imageName: "globe.europe.africa.fill"),
        Preset(name: "HipHop", imageName: "mic")
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                // Step 3: Modify ForEach to use Preset objects
                ForEach(presets) { preset in
                    Button(action: {
                        selectedPreset = preset.name
                    }) {
                        VStack {
                            // Use the imageName from Preset
                            Image(systemName: preset.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .padding()
                            Text(preset.name)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .background(selectedPreset == preset.name ? Color.orange.opacity(0.2) : Color.orange.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
            
            // Hand Selection Button remains unchanged
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
                .background(Color(red: 0.38, green: 0.17, blue: 0))
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

// Sample Preview with Binding
struct EditPresetView_Previews: PreviewProvider {
    @State static var selectedPreset = "Classic"
    
    static var previews: some View {
        EditPresetView(selectedPreset: $selectedPreset)
    }
}
