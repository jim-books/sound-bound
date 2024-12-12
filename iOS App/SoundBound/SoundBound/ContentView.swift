//
//  ContentView.swift
//  SoundBound
//
//  Created by jimbook on 10/12/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var showBluetoothGuide = false
    var body: some View {
        ZStack {
            TabView {
                CoursesView()
                    .tabItem {
                        Label("Courses", systemImage: "book")
                    }
                
                CustomizeView()
                    .tabItem {
                        Label("Customize", systemImage: "paintbrush")
                    }
                
                AccountView()
                    .tabItem {
                        Label("Account", systemImage: "person.circle")
                    }
            }
            .tint(.white)
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showBluetoothGuide.toggle()
                    }) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 70) // Adjust this value as needed
                }
            }
        }
        .sheet(isPresented: $showBluetoothGuide) {
            BluetoothGuideView()
        }
    }
}

#Preview {
    ContentView()
}
