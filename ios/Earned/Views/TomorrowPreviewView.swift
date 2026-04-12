import SwiftUI

struct TomorrowPreviewView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var tomorrowWins: [Win] {
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now) else { return [] }
        return Array(WinLibrary.dailySet(for: tomorrow, count: 5).prefix(3))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sun.horizon.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(EarnedColors.streak)

                Text("TOMORROW'S PREVIEW")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.5)
                    .foregroundStyle(EarnedColors.streak.opacity(0.8))
            }

            VStack(spacing: 0) {
                ForEach(Array(tomorrowWins.enumerated()), id: \.element.id) { index, win in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(win.category.color.opacity(0.15))
                                .frame(width: 32, height: 32)

                            Image(systemName: win.category.icon)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(win.category.color.opacity(0.6))
                        }

                        Text(win.text)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.5))
                            .lineLimit(1)
                            .blur(radius: 3)

                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)

                    if index < tomorrowWins.count - 1 {
                        Rectangle()
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 0.5)
                            .padding(.leading, 58)
                    }
                }

                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10, weight: .bold))
                    Text("Come back tomorrow to reveal")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(.white.opacity(0.35))
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
            }
            .background(.white.opacity(0.05))
            .clipShape(.rect(cornerRadius: 14))
        }
    }
}
