import SwiftUI

struct DailyChallengeCardView: View {
    let viewModel: EarnedViewModel
    private let challenge = DailyChallenge.forToday()

    private var challengeCompleted: Bool {
        guard let targetCategory = challenge.targetCategory else { return false }
        let todayWins = viewModel.todayEarnedWins
        return todayWins.contains { $0.category == targetCategory }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkle")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(challenge.color)

                Text("DAILY CHALLENGE")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.5)
                    .foregroundStyle(challenge.color.opacity(0.8))
            }

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(challenge.color.opacity(challengeCompleted ? 0.25 : 0.12))
                        .frame(width: 44, height: 44)

                    if challengeCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(challenge.color)
                    } else {
                        Image(systemName: challenge.icon)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(challenge.color.opacity(0.7))
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(challenge.title)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)

                        if challengeCompleted {
                            Text("+\(challenge.bonusXP) XP")
                                .font(.caption2.weight(.heavy))
                                .foregroundStyle(challenge.color)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(challenge.color.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }

                    Text(challengeCompleted ? "Challenge complete!" : challenge.description)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(challengeCompleted ? challenge.color : .white.opacity(0.5))
                }

                Spacer()
            }
            .padding(14)
            .background(challengeCompleted ? challenge.color.opacity(0.08) : .white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(challengeCompleted ? challenge.color.opacity(0.2) : .clear, lineWidth: 1)
            )
            .clipShape(.rect(cornerRadius: 14))
        }
    }
}
