import SwiftUI

struct MemoryCardView: View {
    let viewModel: EarnedViewModel

    private var memory: MemoryData? {
        let calendar = Calendar.current
        guard let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: .now) else { return nil }
        let key = DailyEntry.dateKey(for: oneYearAgo)
        guard let entry = viewModel.entries[key], !entry.earnedWinIDs.isEmpty else { return nil }

        let wins = viewModel.earnedWins(for: key)
        return MemoryData(dateKey: key, entry: entry, wins: wins)
    }

    var body: some View {
        if let memory = memory {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(EarnedColors.accentBright)

                    Text("THIS DAY LAST YEAR")
                        .font(.caption2.weight(.heavy))
                        .tracking(1.5)
                        .foregroundStyle(EarnedColors.accentBright.opacity(0.8))
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        if let date = DailyEntry.date(from: memory.dateKey) {
                            Text(date, format: .dateTime.month(.abbreviated).day().year())
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white.opacity(0.5))
                        }

                        Spacer()

                        Text("\(memory.entry.earnedCount) wins")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(EarnedColors.earned)
                    }

                    ForEach(memory.wins.prefix(3)) { win in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(EarnedColors.earned.opacity(0.6))

                            Text(win.text)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                    }

                    if memory.wins.count > 3 {
                        Text("+ \(memory.wins.count - 3) more")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.35))
                    }

                    if let mood = memory.entry.mood {
                        HStack(spacing: 4) {
                            Text("Feeling:")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.white.opacity(0.4))
                            Text(mood.emoji)
                                .font(.caption)
                            Text(mood.label)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(mood.color)
                        }
                    }
                }
                .padding(14)
                .background(.white.opacity(0.06))
                .clipShape(.rect(cornerRadius: 14))
            }
        }
    }
}

private struct MemoryData {
    let dateKey: String
    let entry: DailyEntry
    let wins: [Win]
}
