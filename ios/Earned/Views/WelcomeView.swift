import SwiftUI

struct WelcomeView: View {
    let onComplete: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var currentStep: Int = 0
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 30
    @State private var statCounterValue: Int = 0
    @State private var particlePhase: Bool = false
    @State private var orbPulse: Bool = false
    @State private var finalRevealed: Bool = false
    @State private var buttonOpacity: Double = 0
    @State private var meshPhase: Bool = false

    private let steps: [(text: String, highlight: String?, subtext: String?)] = [
        (
            "You had thousands of thoughts today.",
            nil,
            nil
        ),
        (
            "Research shows up to",
            "80%",
            "of them were negative."
        ),
        (
            "You told yourself you weren't enough.\nThat you could've done more.\nThat you fell short.",
            nil,
            nil
        ),
        (
            "But somewhere in today,\nyou did something that mattered.",
            nil,
            nil
        ),
        (
            "Maybe you showed up.\nMaybe you kept going.\nMaybe you chose kindness\n— even toward yourself.",
            nil,
            nil
        ),
        (
            "Those moments deserve to be remembered.",
            nil,
            nil
        ),
        (
            "Most people say they'd journal\nif it didn't take so long.",
            nil,
            "This takes 60 seconds."
        ),
    ]

    var body: some View {
        ZStack {
            animatedBackground
                .ignoresSafeArea()

            floatingParticles
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                Spacer()

                if currentStep < steps.count {
                    stepContent
                        .padding(.horizontal, 32)
                } else {
                    finalReveal
                        .padding(.horizontal, 32)
                }

                Spacer()

                if currentStep < steps.count {
                    tapPrompt
                        .padding(.bottom, 60)
                } else {
                    beginButton
                        .padding(.horizontal, 24)
                        .padding(.bottom, 60)
                }
            }
        }
        .onAppear {
            animateStep()
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                    meshPhase = true
                }
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    orbPulse = true
                }
                withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                    particlePhase = true
                }
            }
        }
        .onTapGesture {
            advanceStep()
        }
    }

    private var stepContent: some View {
        VStack(spacing: 20) {
            let step = steps[currentStep]

            if let highlight = step.highlight {
                VStack(spacing: 6) {
                    Text(step.text)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)

                    Text(highlight)
                        .font(.system(size: 72, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [EarnedColors.streak, Color(red: 1.0, green: 0.3, blue: 0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .raisedHeadline()
                        .contentTransition(.numericText())

                    if let subtext = step.subtext {
                        Text(subtext)
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                }
            } else {
                Text(step.text)
                    .font(currentStep == 5 ? .title.weight(.bold) : .title2.weight(.semibold))
                    .foregroundStyle(currentStep == 5 ? .white : .white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)

                if let subtext = step.subtext {
                    Text(subtext)
                        .font(.title.weight(.black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [EarnedColors.earned, EarnedColors.earnedBright],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .raisedHeadline()
                }
            }
        }
        .opacity(textOpacity)
        .offset(y: textOffset)
    }

    private var finalReveal: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [EarnedColors.accent.opacity(0.3), EarnedColors.momentum.opacity(0.1), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(orbPulse ? 1.15 : 0.95)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [EarnedColors.accent, EarnedColors.momentum],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                    .shadow(color: EarnedColors.accent.opacity(0.5), radius: 30, y: 10)

                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .black))
                    .foregroundStyle(.white)
            }
            .scaleEffect(finalRevealed ? 1 : 0.3)
            .opacity(finalRevealed ? 1 : 0)

            VStack(spacing: 12) {
                Text("EARNED")
                    .font(.system(size: 38, weight: .black))
                    .tracking(6)
                    .foregroundStyle(.white)
                    .raisedHeadline()

                Text("The easiest way to own your wins.")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .opacity(finalRevealed ? 1 : 0)
            .offset(y: finalRevealed ? 0 : 20)
        }
    }

    private var tapPrompt: some View {
        HStack(spacing: 6) {
            Image(systemName: "hand.tap.fill")
                .font(.caption)
            Text("Tap to continue")
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(.white.opacity(0.3))
        .opacity(textOpacity)
    }

    private var beginButton: some View {
        Button {
            onComplete()
        } label: {
            Text("Begin")
                .font(.headline.weight(.bold))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [EarnedColors.accent, EarnedColors.momentum],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 16))
                .shadow(color: EarnedColors.accent.opacity(0.4), radius: 20, y: 8)
        }
        .opacity(buttonOpacity)
        .sensoryFeedback(.impact(weight: .medium), trigger: currentStep)
    }

    private var animatedBackground: some View {
        ZStack {
            Color(red: 0.02, green: 0.02, blue: 0.08)

            if currentStep <= 2 {
                RadialGradient(
                    colors: [
                        Color(red: 0.15, green: 0.05, blue: 0.2).opacity(0.6),
                        Color(red: 0.05, green: 0.02, blue: 0.12).opacity(0.3),
                        .clear
                    ],
                    center: .center,
                    startRadius: 20,
                    endRadius: 400
                )
            } else if currentStep <= 4 {
                RadialGradient(
                    colors: [
                        EarnedColors.deepViolet.opacity(0.5),
                        EarnedColors.deepIndigo.opacity(0.4),
                        .clear
                    ],
                    center: meshPhase ? .topTrailing : .bottomLeading,
                    startRadius: 50,
                    endRadius: 500
                )
            } else {
                ZStack {
                    RadialGradient(
                        colors: [
                            EarnedColors.accent.opacity(0.15),
                            EarnedColors.momentum.opacity(0.1),
                            .clear
                        ],
                        center: .top,
                        startRadius: 30,
                        endRadius: 450
                    )

                    RadialGradient(
                        colors: [
                            EarnedColors.earned.opacity(0.08),
                            .clear
                        ],
                        center: .bottomLeading,
                        startRadius: 0,
                        endRadius: 300
                    )
                }
            }

            Circle()
                .fill(EarnedColors.accent.opacity(0.06))
                .frame(width: 350, height: 350)
                .blur(radius: 100)
                .offset(
                    x: meshPhase ? 40 : -40,
                    y: meshPhase ? -80 : 80
                )

            Circle()
                .fill(EarnedColors.momentum.opacity(0.05))
                .frame(width: 280, height: 280)
                .blur(radius: 80)
                .offset(
                    x: meshPhase ? -50 : 50,
                    y: meshPhase ? 100 : -40
                )
        }
        .animation(.easeInOut(duration: 1.5), value: currentStep)
    }

    private var floatingParticles: some View {
        Canvas { context, size in
            let particleCount = 20
            for i in 0..<particleCount {
                let seed = Double(i) * 137.508
                let normalizedProgress = particlePhase ? 1.0 : 0.0
                let xBase = (seed.truncatingRemainder(dividingBy: size.width))
                let yBase = Double(i) / Double(particleCount) * size.height
                let drift = sin(seed + normalizedProgress * .pi * 2) * 20
                let x = xBase + drift
                let y = yBase + (normalizedProgress * 30 - 15)

                let alpha = (sin(seed * 0.5 + normalizedProgress * .pi) + 1) / 2 * 0.15 + 0.05
                let radius = CGFloat(1.5 + sin(seed) * 1.0)

                let rect = CGRect(x: x, y: y, width: radius * 2, height: radius * 2)
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(.white.opacity(alpha))
                )
            }
        }
    }

    private func advanceStep() {
        guard currentStep < steps.count else { return }

        if reduceMotion {
            if currentStep < steps.count - 1 {
                currentStep += 1
                textOpacity = 1
                textOffset = 0
            } else {
                currentStep = steps.count
                finalRevealed = true
                buttonOpacity = 1
            }
            return
        }

        withAnimation(.easeOut(duration: 0.2)) {
            textOpacity = 0
            textOffset = -15
        } completion: {
            if currentStep < steps.count - 1 {
                currentStep += 1
                textOffset = 30
                animateStep()
            } else {
                currentStep = steps.count
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    finalRevealed = true
                }
                withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
                    buttonOpacity = 1
                }
            }
        }
    }

    private func animateStep() {
        if reduceMotion {
            textOpacity = 1
            textOffset = 0
            return
        }

        textOpacity = 0
        textOffset = 30

        withAnimation(.easeOut(duration: 0.6).delay(0.15)) {
            textOpacity = 1
            textOffset = 0
        }
    }
}
