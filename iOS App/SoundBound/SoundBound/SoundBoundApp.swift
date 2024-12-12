//
//  SoundBoundApp.swift
//  SoundBound
//
//  Created by jimbook on 10/12/2024.
//

import SwiftUI

@main
struct SoundBoundApp: App {
    
    @StateObject private var bleManager = BLEManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environmentObject(bleManager) // Injecting BLEManager into the environment
        }
    }
}
