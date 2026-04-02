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
                    onComplete()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.body.weight(.semibold))
                        Text("I Said It")
                            .font(.body.weight(.bold))
                    }
                    .frame(maxWidth: isWide ? 400 : .infinity)
                    .frame(height: 54)
                    .background(EarnedColors.primaryGradient)
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .opacity(statementVisible ? 1 : 0)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(1.1), value: statementVisible)
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
