//
//  SplashScreenView.swift
//  InventoryV3
//
//  Created by Marcus Deuß on 09.03.26.
//

import SwiftUI

struct SplashScreenView: View {
    let onFinished: () -> Void

    @State private var logoScale: CGFloat = 0.35
    @State private var logoOpacity: CGFloat = 0
    @State private var titleOffset: CGFloat = 28
    @State private var titleOpacity: CGFloat = 0
    @State private var taglineOpacity: CGFloat = 0
    @State private var glowOpacity: CGFloat = 0

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Logo + glow
                ZStack {
                    // Soft glow ring behind the logo
                    Circle()
                        .fill(Color(red: 0.35, green: 0.45, blue: 1.0).opacity(0.25))
                        .frame(width: 200, height: 200)
                        .blur(radius: 32)
                        .opacity(glowOpacity)

                    AppLogoView(size: 130)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                }

                VStack(spacing: 8) {
                    Text("Inventory")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.white)
                        .offset(y: titleOffset)
                        .opacity(titleOpacity)

                    Text("Everything in its place.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.60))
                        .opacity(taglineOpacity)
                }

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            runAnimations()
        }
    }

    // MARK: - Background

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(red: 0.10, green: 0.04, blue: 0.28), location: 0),
                .init(color: Color(red: 0.04, green: 0.18, blue: 0.52), location: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Animation sequence

    private func runAnimations() {
        // Logo springs in
        withAnimation(.spring(duration: 0.8, bounce: 0.45)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        // Glow pulses in slightly after logo
        withAnimation(.easeOut(duration: 0.6).delay(0.15)) {
            glowOpacity = 1.0
        }

        // Title slides up and fades in
        withAnimation(.easeOut(duration: 0.55).delay(0.42)) {
            titleOffset = 0
            titleOpacity = 1.0
        }

        // Tagline fades in last
        withAnimation(.easeIn(duration: 0.45).delay(0.75)) {
            taglineOpacity = 1.0
        }

        // Dismiss after display time
        Task {
            try? await Task.sleep(for: .seconds(2.6))
            onFinished()
        }
    }
}

#Preview {
    SplashScreenView(onFinished: {})
}
