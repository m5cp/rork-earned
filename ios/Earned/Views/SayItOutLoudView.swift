import SwiftUI

struct SayItOutLoudView: View {
    let statement: String
    let onComplete: () -> Void
    let onDismiss: () -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared: Bool = false
    @State private var statementVisible: Bool = false
    @State private var quoteVisible: Bool = false
    @State private var didSayIt: Bool = false
    @State private var buttonPulse: Bool = false

    private var isWide: Bool { horizontalSizeClass == .regular }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        onDismiss()
                    } label: {
                        Text("Not now")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.secondarySystemFill))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                VStack(spacing: 36) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(EarnedColors.accent.opacity(0.5))
                        .opacity(quoteVisible ? 1 : 0)
                        .scaleEffect(quoteVisible ? 1 : 0.5)
                        .animation(reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.65).delay(0.2), value: quoteVisible)

                    VStack(spacing: 20) {
                        Text(statement)
                            .font(isWide ? .largeTitle.weight(.black) : .system(.title, weight: .black))
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)
                            .padding(.horizontal, isWide ? 64 : 32)
                            .opacity(statementVisible ? 1 : 0)
                            .offset(y: reduceMotion ? 0 : (statementVisible ? 0 : 20))
                            .animation(reduceMotion ? nil : .easeOut(duration: 0.7).delay(0.5), value: statementVisible)

                        Capsule()
                            .fill(EarnedColors.primaryGradient)
                            .frame(width: 36, height: 3)
                            .opacity(statementVisible ? 1 : 0)
                            .scaleEffect(x: statementVisible ? 1 : 0)
                            .animation(reduceMotion ? nil : .easeOut(duration: 0.5).delay(0.8), value: statementVisible)

                        Text("Say it. Own it.")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(EarnedColors.accent)
                            .opacity(statementVisible ? 1 : 0)
                            .animation(reduceMotion ? nil : .easeOut(duration: 0.5).delay(0.9), value: statementVisible)
                    }
                }
                .frame(maxWidth: isWide ? 520 : .infinity)

                Spacer()

                Button {
                    guard !didSayIt else { return }
                    didSayIt = true
                    withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.5)) {
                        buttonPulse = true
                    }
                    Task {
                        try? await Task.sleep(for: .milliseconds(600))
                        onComplete()
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: didSayIt ? "star.fill" : "checkmark.circle.fill")
                            .font(.title3.weight(.bold))
                            .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp)))
                        Text(didSayIt ? "You Owned It!" : "I Said It")
                            .font(.title3.weight(.heavy))
                            .contentTransition(.numericText())
                    }
                    .frame(maxWidth: isWide ? 400 : .infinity)
                    .frame(height: 60)
                    .background(
                        ZStack {
                            EarnedColors.primaryGradient
                            if didSayIt {
                                Color.white.opacity(0.15)
                            }
                        }
                    )
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 18))
                    .scaleEffect(buttonPulse ? 1.08 : 1.0)
                    .shadow(color: didSayIt ? EarnedColors.accent.opacity(0.5) : .clear, radius: didSayIt ? 16 : 0, y: 4)
                    .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.5), value: buttonPulse)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: didSayIt)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .opacity(statementVisible ? 1 : 0)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(1.1), value: statementVisible)
                .sensoryFeedback(.success, trigger: didSayIt)
            }
        }
        .onAppear {
            if reduceMotion {
                appeared = true
                quoteVisible = true
                statementVisible = true
            } else {
                withAnimation { appeared = true }
                quoteVisible = true
                statementVisible = true
            }
        }
        .sensoryFeedback(.impact(flexibility: .solid, intensity: 0.5), trigger: appeared)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Say it out loud: \(statement)")
    }
}
