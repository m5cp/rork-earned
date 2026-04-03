import SwiftUI

struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    @State private var glowRadius: CGFloat = 0
    @State private var backgroundVisible: Bool = false
    @State private var orbOffset1: CGFloat = -80
    @State private var orbOffset2: CGFloat = 60
    @State private var checkmarkTrim: CGFloat = 0

    let onFinished: () -> Void

    var body: some View {
        ZStack {
            background
                .ignoresSafeArea()
                .opacity(backgroundVisible ? 1 : 0)

            VStack(spacing: 24) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(EarnedColors.accent.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .blur(radius: glowRadius)

                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [EarnedColors.accent, EarnedColors.momentum],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 88, height: 88)
                            .shadow(color: EarnedColors.accent.opacity(0.4), radius: 20, y: 8)

                        Image(systemName: "checkmark")
                            .font(.system(size: 38, weight: .black))
                            .foregroundStyle(.white)
                    }
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                VStack(spacing: 10) {
                    Text("EARNED")
                        .font(.system(size: 34, weight: .black))
                        .tracking(6)
                        .foregroundStyle(.white)

                    Text("Own your wins.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .opacity(taglineOpacity)
                .offset(y: taglineOpacity > 0 ? 0 : 12)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            runAnimation()
        }
    }

    private var background: some View {
        ZStack {
            EarnedColors.immersiveGradient

            Circle()
                .fill(EarnedColors.accent.opacity(0.12))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(y: orbOffset1)

            Circle()
                .fill(EarnedColors.momentum.opacity(0.1))
                .frame(width: 250, height: 250)
                .blur(radius: 70)
                .offset(x: 60, y: orbOffset2)
        }
    }

    private func runAnimation() {
        if reduceMotion {
            backgroundVisible = true
            logoScale = 1.0
            logoOpacity = 1
            taglineOpacity = 1
            glowRadius = 30

            Task {
                try? await Task.sleep(for: .seconds(1.0))
                onFinished()
            }
            return
        }

        withAnimation(.easeOut(duration: 0.4)) {
            backgroundVisible = true
        }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.2)) {
            logoScale = 1.0
            logoOpacity = 1
        }

        withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
            glowRadius = 30
        }

        withAnimation(.easeInOut(duration: 1.2).delay(0.3)) {
            orbOffset1 = -60
            orbOffset2 = 80
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.55)) {
            taglineOpacity = 1
        }

        Task {
            try? await Task.sleep(for: .seconds(2.0))
            onFinished()
        }
    }
}
