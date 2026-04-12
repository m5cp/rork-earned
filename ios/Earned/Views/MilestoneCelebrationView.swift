import SwiftUI

struct MilestoneCelebrationView: View {
    let milestone: Milestone
    let onDismiss: () -> Void
    let onShare: () -> Void
    @State private var appeared: Bool = false
    @State private var ringRotation: Double = 0
    @State private var confettiParticles: [ConfettiParticle] = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color.black.opacity(appeared ? 0.7 : 0)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            if !reduceMotion {
                confettiLayer
            }

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .strokeBorder(
                                AngularGradient(
                                    colors: [milestone.color, milestone.color.opacity(0.3), milestone.color],
                                    center: .center
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 100, height: 100)
                            .rotationEffect(.degrees(ringRotation))

                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [milestone.color.opacity(0.4), milestone.color.opacity(0.1)],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 44
                                )
                            )
                            .frame(width: 88, height: 88)

                        Image(systemName: milestone.icon)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(milestone.color)
                    }
                    .scaleEffect(appeared ? 1 : 0.3)

                    VStack(spacing: 8) {
                        Text("MILESTONE UNLOCKED")
                            .font(.caption2.weight(.heavy))
                            .tracking(2.5)
                            .foregroundStyle(milestone.color)

                        Text(milestone.title)
                            .font(.system(size: 28, weight: .black))
                            .foregroundStyle(.white)

                        Text(milestone.description)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    VStack(spacing: 12) {
                        Button {
                            onShare()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.subheadline.weight(.bold))
                                Text("Share")
                                    .font(.subheadline.weight(.bold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(.white)
                            .foregroundStyle(Color(red: 0.04, green: 0.05, blue: 0.14))
                            .clipShape(.rect(cornerRadius: 14))
                        }

                        Button {
                            onDismiss()
                        } label: {
                            Text("Continue")
                                .font(.subheadline.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(.white.opacity(0.12))
                                .foregroundStyle(.white.opacity(0.9))
                                .clipShape(.rect(cornerRadius: 14))
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 4)
                }
                .padding(28)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.08, green: 0.08, blue: 0.2),
                                        Color(red: 0.04, green: 0.04, blue: 0.12),
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                RadialGradient(
                                    colors: [milestone.color.opacity(0.1), Color.clear],
                                    center: .top,
                                    startRadius: 0,
                                    endRadius: 200
                                )
                            )

                        RoundedRectangle(cornerRadius: 28)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [milestone.color.opacity(0.3), Color.white.opacity(0.06)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                )
                .padding(.horizontal, 24)
                .scaleEffect(appeared ? 1 : 0.9)
                .opacity(appeared ? 1 : 0)

                Spacer()
            }
        }
        .onAppear {
            if reduceMotion {
                appeared = true
            } else {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    appeared = true
                }
                withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                    ringRotation = 360
                }
                spawnConfetti()
            }
        }
        .sensoryFeedback(.impact(weight: .heavy, intensity: 1.0), trigger: appeared)
        .sensoryFeedback(.success, trigger: ringRotation)
    }

    private func spawnConfetti() {
        let colors: [Color] = [milestone.color, EarnedColors.accent, EarnedColors.earned, EarnedColors.streak, EarnedColors.momentum, .white]
        for i in 0..<40 {
            let particle = ConfettiParticle(
                id: i,
                color: colors[i % colors.count],
                x: CGFloat.random(in: 0...1),
                delay: Double.random(in: 0...0.6),
                speed: Double.random(in: 1.8...3.5),
                rotation: Double.random(in: -360...360),
                size: CGFloat.random(in: 4...10)
            )
            confettiParticles.append(particle)
        }
    }

    private var confettiLayer: some View {
        GeometryReader { geo in
            ForEach(confettiParticles) { particle in
                ConfettiPiece(particle: particle, appeared: appeared, size: geo.size)
            }
        }
        .allowsHitTesting(false)
    }
}

struct ConfettiParticle: Identifiable {
    let id: Int
    let color: Color
    let x: CGFloat
    let delay: Double
    let speed: Double
    let rotation: Double
    let size: CGFloat
}

struct ConfettiPiece: View {
    let particle: ConfettiParticle
    let appeared: Bool
    let size: CGSize
    @State private var fallen: Bool = false

    var body: some View {
        RoundedRectangle(cornerRadius: 1.5)
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size * 0.6)
            .rotationEffect(.degrees(fallen ? particle.rotation : 0))
            .position(
                x: size.width * particle.x,
                y: fallen ? size.height + 40 : -20
            )
            .opacity(fallen ? 0 : 1)
            .onAppear {
                guard appeared else { return }
                withAnimation(
                    .easeIn(duration: particle.speed)
                    .delay(particle.delay)
                ) {
                    fallen = true
                }
            }
    }
}
