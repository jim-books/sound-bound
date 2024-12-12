//
//  HandSelectionView.swift
//  SoundBound
//
//  Created by jimbook on 12/12/2024.
//

import SwiftUI

struct HandSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedHand: String? = nil
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Select Your Handedness")
                .font(.title2)
                .padding()
            
            HStack(spacing: 50) {
                // Left Hand
                Button(action: {
                    selectedHand = "Left"
                    // Handle left-handed selection
                    presentationMode.wrappedValue.dismiss()
                }) {
                    VStack {
                        Image(systemName: "hand.raised.left.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(selectedHand == "Left" ? .blue : .gray)
                        Text("Left")
                    }
                }
                
                // Right Hand
                Button(action: {
                    selectedHand = "Right"
                    // Handle right-handed selection
                    presentationMode.wrappedValue.dismiss()
                }) {
                    VStack {
                        Image(systemName: "hand.raised.right.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(selectedHand == "Right" ? .blue : .gray)
                        Text("Right")
                    }
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    HandSelectionView()
}
