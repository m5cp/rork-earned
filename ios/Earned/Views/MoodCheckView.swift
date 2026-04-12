import SwiftUI

struct MoodCheckView: View {
    let onMoodSelected: (Mood) -> Void
    let onSkip: () -> Void
    @State private var selectedMood: Mood?
    @State private var appeared: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            backgroundLayer.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 32) {
                    VStack(spacing: 12) {
                        Text("HOW ARE YOU FEELING?")
                            .font(.caption2.weight(.heavy))
                            .tracking(3)
                            .foregroundStyle(EarnedColors.accentBright)
                            .raisedText()

                        Text("One tap. That's it.")
                            .font(.system(size: 26, weight: .black))
                            .foregroundStyle(.white)
                            .raisedHeadline()
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: reduceMotion ? 0 : (appeared ? 0 : 12))
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.5), value: appeared)

                    HStack(spacing: 16) {
                        ForEach(Array(Mood.allCases.enumerated()), id: \.element.id) { index, mood in
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    selectedMood = mood
                                }
                                Task {
                                    try? await Task.sleep(for: .milliseconds(400))
                                    onMoodSelected(mood)
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    Text(mood.emoji)
                                        .font(.system(size: 38))
                                        .scaleEffect(selectedMood == mood ? 1.25 : 1.0)

                                    Text(mood.label)
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(selectedMood == mood ? .white : .white.opacity(0.5))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedMood == mood ? mood.color.opacity(0.25) : .white.opacity(0.06))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(selectedMood == mood ? mood.color.opacity(0.5) : .clear, lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: reduceMotion ? 0 : (appeared ? 0 : 16))
                            .animation(reduceMotion ? nil : .spring(response: 0.5).delay(0.1 + Double(index) * 0.06), value: appeared)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()

                Button {
                    onSkip()
                } label: {
                    Text("Skip")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.bottom, 48)
                .opacity(appeared ? 1 : 0)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.5), value: appeared)
            }
        }
        .onAppear {
            if reduceMotion { appeared = true }
            else { withAnimation(.easeOut(duration: 0.5)) { appeared = true } }
        }
        .sensoryFeedback(.selection, trigger: selectedMood)
    }

    private var backgroundLayer: some View {
        ZStack {
            EarnedColors.immersiveGradient

            RadialGradient(
                colors: [EarnedColors.momentum.opacity(0.15), Color.clear],
                center: .center,
                startRadius: 0,
                endRadius: 300
            )

            LinearGradient(
                colors: [Color.black.opacity(0.15), Color.clear, Color.clear, Color.black.opacity(0.25)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
