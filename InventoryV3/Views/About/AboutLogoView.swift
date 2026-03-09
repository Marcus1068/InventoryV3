//
//  AboutLogoView.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import SwiftUI

struct AboutLogoView: View {
    @State private var animating = false
    @State private var glowAnimating = false

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Outer glow ring
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.35, green: 0.45, blue: 1.0).opacity(0.45),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(glowAnimating ? 1.18 : 0.82)
                    .opacity(glowAnimating ? 1.0 : 0.35)
                    .blur(radius: 8)

                // Inner glow
                Circle()
                    .fill(Color(red: 0.4, green: 0.5, blue: 1.0).opacity(0.25))
                    .frame(width: 130, height: 130)
                    .scaleEffect(glowAnimating ? 1.08 : 0.94)
                    .blur(radius: 4)

                // Logo
                AppLogoView(size: 104)
                    .scaleEffect(animating ? 1.04 : 0.97)
                    .offset(y: animating ? -7 : 7)
                    .shadow(
                        color: Color(red: 0.3, green: 0.4, blue: 1.0).opacity(animating ? 0.55 : 0.20),
                        radius: animating ? 28 : 12
                    )
            }

            VStack(spacing: 4) {
                Text("Inventory")
                    .font(.title2)
                    .bold()
                Text("Version \(Bundle.main.appVersion)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.8).repeatForever(autoreverses: true)
            ) {
                animating = true
            }
            withAnimation(
                .easeInOut(duration: 3.4).repeatForever(autoreverses: true).delay(0.3)
            ) {
                glowAnimating = true
            }
        }
    }
}

#Preview {
    AboutLogoView()
        .padding()
}
