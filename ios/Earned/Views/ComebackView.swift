import SwiftUI

struct ComebackView: View {
    let onContinue: () -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared: Bool = false
    @State private var textVisible: Bool = false
    @State private var buttonVisible: Bool = false

    private var isWide: Bool { horizontalSizeClass == .regular }

    private var headline: String {
        let options = [
            "You're back.",
            "You showed up.",
            "That counts.",
            "Right back at it.",
            "Keep going."
        ]
        let dayHash = abs(DailyEntry.dateKey().hashValue)
        return options[dayHash % options.count]
    }

    private var subtext: String {
        let options = [
            "Showing up is how progress is built.",
            "Coming back is part of the process.",
            "You didn't quit — you returned.",
            "Progress continues from here.",
            "This still counts."
        ]
        let dayHash = abs(DailyEntry.dateKey().hashValue)
        return options[(dayHash / 5) % options.count]
    }

    var body: some View {
        ZStack {
            backgroundLayer
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 36) {
                    ZStack {
                        Circle()
                            .fill(EarnedColors.accent.opacity(0.12))
                            .frame(width: 96, height: 96)
                            .scaleEffect(appeared ? 1.08 : 0.8)
                            .opacity(appeared ? 1 : 0)
                            .animation(reduceMotion ? nil : .easeOut(duration: 1.4).repeatForever(autoreverses: true), value: appeared)

                        Circle()
                            .fill(EarnedColors.accent.opacity(0.2))
                            .frame(width: 68, height: 68)
                            .scaleEffect(appeared ? 1 : 0.6)
                            .opacity(appeared ? 1 : 0)

                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(.white)
                            .opacity(appeared ? 1 : 0)
                            .scaleEffect(appeared ? 1 : 0.5)
                    }
                    .animation(reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)

                    VStack(spacing: 14) {
                        Text(headline)
                            .font(.system(size: isWide ? 42 : 34, weight: .black))
                            .foregroundStyle(.white)
                            .raisedHeadline()
                            .multilineTextAlignment(.center)
                            .opacity(textVisible ? 1 : 0)
                            .offset(y: reduceMotion ? 0 : (textVisible ? 0 : 20))
                            .animation(reduceMotion ? nil : .easeOut(duration: 0.6).delay(0.3), value: textVisible)

                        Text(subtext)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.85))
                            .raisedText()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .opacity(textVisible ? 1 : 0)
                            .offset(y: reduceMotion ? 0 : (textVisible ? 0 : 12))
                            .animation(reduceMotion ? nil : .easeOut(duration: 0.5).delay(0.5), value: textVisible)
                    }
                }
                .frame(maxWidth: isWide ? 520 : .infinity)

                Spacer()

                Button {
                    onContinue()
                } label: {
                    Text("Continue")
                        .font(.body.weight(.bold))
                        .frame(maxWidth: isWide ? 400 : .infinity)
                        .frame(height: 56)
                        .background(EarnedColors.primaryGradient)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .opacity(buttonVisible ? 1 : 0)
                .offset(y: reduceMotion ? 0 : (buttonVisible ? 0 : 16))
                .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.7), value: buttonVisible)
            }
        }
        .onAppear {
            if reduceMotion {
                appeared = true
                textVisible = true
                buttonVisible = true
            } else {
                withAnimation { appeared = true }
                textVisible = true
                buttonVisible = true
            }
        }
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.6), trigger: appeared)
    }

    private var backgroundLayer: some View {
        ZStack {
            EarnedColors.immersiveGradient

            RadialGradient(
                colors: [
                    EarnedColors.accent.opacity(0.15),
                    Color.clear,
                ],
                center: .center,
                startRadius: 20,
                endRadius: 280
            )
            .offset(y: -40)

            RadialGradient(
                colors: [
                    EarnedColors.momentum.opacity(0.08),
                    Color.clear,
                ],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 200
            )
        }
    }
}
