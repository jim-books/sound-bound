//
//  CoursesView.swift
//  SoundBound
//
//  Created by jimbook on 12/12/2024.
//

import SwiftUI

struct CoursesView: View {
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
                    Text("Courses Details Go Here")
                        .navigationTitle("Account")
                }
                .padding(.bottom, 80)
            }
        }
    }
}
#Preview {
    CoursesView()
}
