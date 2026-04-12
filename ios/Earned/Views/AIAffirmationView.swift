import SwiftUI

struct AIAffirmationView: View {
    let viewModel: EarnedViewModel
    @State private var affirmation: String?
    @State private var isGenerating: Bool = false
    @State private var appeared: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if let affirmation {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(EarnedColors.streak)

                    Text("TODAY'S AFFIRMATION")
                        .font(.caption2.weight(.heavy))
                        .tracking(1.5)
                        .foregroundStyle(EarnedColors.streak.opacity(0.8))
                }

                Text(affirmation)
                    .font(.body.weight(.semibold).italic())
                    .foregroundStyle(.white.opacity(0.9))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.06))
            .clipShape(.rect(cornerRadius: 16))
            .opacity(appeared ? 1 : 0)
            .offset(y: reduceMotion ? 0 : (appeared ? 0 : 8))
            .animation(reduceMotion ? nil : .easeOut(duration: 0.5).delay(0.2), value: appeared)
        } else if isGenerating {
            HStack(spacing: 10) {
                ProgressView()
                    .tint(EarnedColors.streak)
                Text("Crafting your affirmation...")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.04))
            .clipShape(.rect(cornerRadius: 14))
        } else {
            EmptyView()
        }
    }

    func generate() {
        guard affirmation == nil, !isGenerating else { return }
        isGenerating = true
        appeared = false

        Task {
            do {
                let result = try await GroqService.shared.generatePersonalizedAffirmation(
                    recentWins: viewModel.todayEarnedWins,
                    mood: viewModel.todayEntry?.mood,
                    streak: viewModel.currentStreak
                )
                affirmation = result
                isGenerating = false
                if reduceMotion { appeared = true }
                else { withAnimation(.easeOut(duration: 0.5)) { appeared = true } }
            } catch {
                isGenerating = false
            }
        }
    }
}
