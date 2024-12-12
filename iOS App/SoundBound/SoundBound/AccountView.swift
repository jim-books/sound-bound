//
//  AccountView.swift
//  SoundBound
//
//  Created by jimbook on 12/12/2024.
//

import SwiftUI

struct AccountView: View {
    var body: some View {
        NavigationView {
            ZStack{
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.orange.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    Text("Account Details Go Here")
                        .navigationTitle("Account")
                }
                .padding(.bottom, 80)
            }
        }
    }
}

#Preview {
    AccountView()
}
