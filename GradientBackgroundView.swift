//
//  GradientBackgroundView.swift
//  Glasscast
//

import SwiftUI

struct GradientBackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.10, green: 0.14, blue: 0.28),
                Color(red: 0.05, green: 0.10, blue: 0.20)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

