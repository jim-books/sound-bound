//
//  HandSelectionView.swift
//  SoundBound
//
//  Created by jimbook on 12/12/2024.
//

import SwiftUI

struct HandSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedHand: String? = "Right"
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Select Your Handedness")
                .font(.title2)
                .padding()
            
            HStack(spacing: 50) { // Adjust spacing as needed
                // Left Hand Image
                Image(.left)
                    .resizable()
                    .scaledToFit()
                    .opacity((selectedHand == "Left" ? 1 : 0.3))
                    .onTapGesture {
                        selectedHand = "Left"
                        // Handle left-handed selection
//                        presentationMode.wrappedValue.dismiss()
                    }
                
                // Right Hand Image
                Image(.right)
                    .resizable()
                    .scaledToFit()
                    .opacity((selectedHand == "Right" ? 1 : 0.3))
                    .onTapGesture {
                        selectedHand = "Right"
                        // Handle right-handed selection
//                        presentationMode.wrappedValue.dismiss()
                    }
            }
            .padding(.bottom)
        }
    }
}

#Preview {
    HandSelectionView()
}
