import SwiftUI

struct WeeklyInsightView: View {
    let viewModel: EarnedViewModel
    @State private var insightText: String?
    @State private var isGenerating: Bool = false
    @State private var error: String?
    @State private var appeared: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var weekEntries: [(date: String, earnedCount: Int, mood: Mood?, categories: [String])] {
        let calendar = Calendar.current
        var result: [(date: String, earnedCount: Int, mood: Mood?, categories: [String])] = []
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: .now) else { continue }
            let key = DailyEntry.dateKey(for: date)
            guard let entry = viewModel.entries[key] else { continue }
            let wins = viewModel.earnedWins(for: key)
            let cats = Array(Set(wins.map { $0.category.displayName }))
            result.append((date: key, earnedCount: entry.earnedCount, mood: entry.mood, categories: cats))
        }
        return result
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection

                if isGenerating {
                    generatingCard
                } else if let insight = insightText {
                    insightCard(insight)
                } else {
                    generateButton
                }

                weekOverviewSection

                if let error {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Weekly Insight")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if reduceMotion { appeared = true }
            else { withAnimation(.easeOut(duration: 0.5)) { appeared = true } }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [EarnedColors.momentum.opacity(0.3), EarnedColors.momentum.opacity(0.1)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 40
                        )
                    )
                    .frame(width: 72, height: 72)

                Image(systemName: "brain.head.profile.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(EarnedColors.momentum)
            }
            .scaleEffect(appeared ? 1 : 0.7)
            .opacity(appeared ? 1 : 0)
            .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.7), value: appeared)

            VStack(spacing: 6) {
                Text("Your Week in Review")
                    .font(.title3.weight(.bold))

                Text("\(viewModel.weeklyEarnedCount) wins across \(viewModel.daysActiveInLast(7)) days")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .opacity(appeared ? 1 : 0)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.1), value: appeared)
        }
        .padding(.vertical, 12)
    }

    private var generatingCard: some View {
        HStack(spacing: 14) {
            ProgressView()

            VStack(alignment: .leading, spacing: 4) {
                Text("Analyzing your week...")
                    .font(.subheadline.weight(.semibold))
                Text("AI is finding patterns in your data")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func insightCard(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(EarnedColors.momentum)

                Text("AI INSIGHT")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.5)
                    .foregroundStyle(EarnedColors.momentum)
            }

            Text(text)
                .font(.body)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 18))
        .opacity(appeared ? 1 : 0)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.15), value: appeared)
    }

    private var generateButton: some View {
        Button {
            generateInsight()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.body.weight(.bold))
                Text("Generate Weekly Insight")
                    .font(.body.weight(.bold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(EarnedColors.primaryGradient)
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private var weekOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("THIS WEEK")
                .font(.caption.weight(.heavy))
                .tracking(1.5)
                .foregroundStyle(.secondary)

            VStack(spacing: 0) {
                ForEach(Array(weekEntries.enumerated()), id: \.element.date) { index, entry in
                    HStack(spacing: 14) {
                        if let date = DailyEntry.date(from: entry.date) {
                            Text(date, format: .dateTime.weekday(.abbreviated))
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                                .frame(width: 30)
                        }

                        if let mood = entry.mood {
                            Text(mood.emoji)
                                .font(.caption)
                        } else {
                            Text("—")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }

                        Text("\(entry.earnedCount) wins")
                            .font(.subheadline.weight(.medium))

                        Spacer()

                        HStack(spacing: 4) {
                            ForEach(entry.categories.prefix(3), id: \.self) { cat in
                                Text(cat)
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(.tertiarySystemFill))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)

                    if index < weekEntries.count - 1 {
                        Divider().padding(.leading, 58)
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
        .opacity(appeared ? 1 : 0)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.2), value: appeared)
    }

    private func generateInsight() {
        isGenerating = true
        error = nil

        Task {
            do {
                let result = try await GroqService.shared.generateWeeklyInsight(
                    weekEntries: weekEntries,
                    totalWins: viewModel.weeklyEarnedCount,
                    streak: viewModel.currentStreak
                )
                insightText = result
                isGenerating = false
            } catch {
                self.error = error.localizedDescription
                isGenerating = false
            }
        }
    }
}
