import SwiftUI

struct WeeklyMomentumDetailView: View {
    let viewModel: EarnedViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared: Bool = false

    private var momentum: WeeklyMomentum { viewModel.weeklyMomentum }
    private var highlights: [MomentumHighlight] { momentum.highlights }

    private var dateRangeLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let start = formatter.string(from: momentum.weekStartDate)
        let end = formatter.string(from: momentum.weekEndDate)
        return "\(start) – \(end)"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    heroSection
                    if !momentum.isEmpty {
                        weekDayDots
                        highlightsSection
                        statsGrid
                    }
                    howItWorksSection
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 48)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Weekly Momentum")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(EarnedColors.momentum)
                }
            }
            .onAppear {
                if reduceMotion { appeared = true }
                else { withAnimation(.easeOut(duration: 0.6)) { appeared = true } }
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [EarnedColors.momentum.opacity(0.3), EarnedColors.momentum.opacity(0.05)],
                            center: .center,
                            startRadius: 10,
                            endRadius: 60
                        )
                    )
                    .frame(width: 100, height: 100)

                if momentum.isEmpty {
                    Image(systemName: "bolt")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(EarnedColors.momentum.opacity(0.4))
                } else {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(EarnedColors.momentum)
                        .symbolEffect(.bounce, value: appeared)
                }
            }
            .scaleEffect(appeared ? 1 : 0.7)
            .opacity(appeared ? 1 : 0)
            .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.7), value: appeared)

            VStack(spacing: 6) {
                Text(viewModel.weeklyMomentumHeadline)
                    .font(.title2.weight(.heavy))
                    .multilineTextAlignment(.center)

                Text(viewModel.weeklyMomentumSubheadline)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(EarnedColors.momentum)
                    .multilineTextAlignment(.center)

                Text(dateRangeLabel)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.tertiary)
                    .padding(.top, 2)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: reduceMotion ? 0 : (appeared ? 0 : 12))
            .animation(reduceMotion ? nil : .easeOut(duration: 0.5).delay(0.1), value: appeared)
        }
        .padding(.vertical, 8)
    }

    private var weekDayDots: some View {
        let data = viewModel.recentWeekData()

        return VStack(alignment: .leading, spacing: 12) {
            Text("THIS WEEK")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(EarnedColors.momentum)

            HStack(spacing: 0) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    let key = DailyEntry.dateKey(for: item.date)
                    let entry = viewModel.entries[key]
                    let hasActivity = (entry?.earnedCount ?? 0) > 0
                    let isComeback = entry?.isComeback == true
                    let isToday = Calendar.current.isDateInToday(item.date)

                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(dotColor(hasActivity: hasActivity, isComeback: isComeback, isToday: isToday))
                                .frame(width: 32, height: 32)

                            if hasActivity {
                                Image(systemName: "checkmark")
                                    .font(.caption2.weight(.heavy))
                                    .foregroundStyle(.white)
                            } else if isToday {
                                Circle()
                                    .fill(EarnedColors.accent.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                        }

                        Text(shortDay(item.date))
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(isToday ? .primary : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .opacity(appeared ? 1 : 0)
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.3).delay(0.2 + Double(index) * 0.04), value: appeared)
                }
            }
        }
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 18))
        .opacity(appeared ? 1 : 0)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.15), value: appeared)
    }

    private func dotColor(hasActivity: Bool, isComeback: Bool, isToday: Bool) -> Color {
        if hasActivity && isComeback {
            return EarnedColors.momentum
        }
        if hasActivity {
            return EarnedColors.earned
        }
        if isToday {
            return Color(.quaternarySystemFill)
        }
        return Color(.tertiarySystemFill)
    }

    private func shortDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(2))
    }

    private var highlightsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("HIGHLIGHTS")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(EarnedColors.momentum)
                .padding(.horizontal, 4)

            if highlights.isEmpty {
                Text("Keep going. Your highlights will appear here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(.rect(cornerRadius: 18))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(highlights.enumerated()), id: \.element.id) { index, highlight in
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(EarnedColors.momentum.opacity(0.12))
                                    .frame(width: 40, height: 40)

                                Image(systemName: highlight.icon)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(EarnedColors.momentum)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(highlight.label)
                                    .font(.subheadline.weight(.semibold))

                                Text(highlight.detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 6))
                        .animation(reduceMotion ? nil : .spring(response: 0.4).delay(0.3 + Double(index) * 0.06), value: appeared)

                        if index < highlights.count - 1 {
                            Divider().padding(.leading, 70)
                        }
                    }
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 18))
            }
        }
        .opacity(appeared ? 1 : 0)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.25), value: appeared)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statBlock(
                value: "\(momentum.daysActive)",
                label: "Days Active",
                icon: "calendar",
                color: EarnedColors.accent
            )

            statBlock(
                value: "\(momentum.totalEarned)",
                label: "Wins Earned",
                icon: "checkmark.circle.fill",
                color: EarnedColors.earned
            )

            statBlock(
                value: "\(momentum.sayItOutLoudCount)",
                label: "Declared",
                icon: "quote.opening",
                color: Color(red: 0.55, green: 0.35, blue: 1.0)
            )

            statBlock(
                value: "\(momentum.comebackCount)",
                label: "Comebacks",
                icon: "heart.fill",
                color: EarnedColors.momentum
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 8))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.35), value: appeared)
    }

    private func statBlock(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(color)

            Text(value)
                .font(.system(.title2, design: .rounded, weight: .black))
                .foregroundStyle(.primary)

            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text("How It Works")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text("MVM Earned uses your activity in the app to recognize progress, consistency, and return behavior.")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Text("Built from what you do. Never from what you missed.")
                .font(.caption.weight(.semibold))
                .foregroundStyle(EarnedColors.momentum.opacity(0.7))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground).opacity(0.6))
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.4), value: appeared)
    }
}
