import SwiftUI

struct EarnedProgressView: View {
    let viewModel: EarnedViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared: Bool = false
    @State private var selectedDate: Date?

    private var isWide: Bool { horizontalSizeClass == .regular }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    statsCards
                    WeeklyMomentumCardView(viewModel: viewModel)
                    calendarSection
                    weeklyTrendChart
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 40)
                .frame(maxWidth: isWide ? 720 : .infinity)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Progress")
            .onAppear {
                if reduceMotion { appeared = true }
                else { withAnimation(.easeOut(duration: 0.5)) { appeared = true } }
            }
            .sheet(item: $selectedDate) { date in
                DayDetailView(viewModel: viewModel, date: date)
            }
        }
    }

    private var statsCards: some View {
        HStack(spacing: 12) {
            statCard(
                value: viewModel.consistencyRatio,
                label: "This Week",
                icon: "calendar",
                gradient: EarnedColors.primaryGradient
            )

            statCard(
                value: "\(viewModel.totalDaysCheckedIn)",
                label: "Total Days",
                icon: "checkmark.circle.fill",
                gradient: EarnedColors.earnedGradient
            )

            statCard(
                value: "\(viewModel.monthlyEarnedCount)",
                label: "This Month",
                icon: "chart.bar.fill",
                gradient: EarnedColors.streakGradient
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 10))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4), value: appeared)
    }

    private func statCard(value: String, label: String, icon: String, gradient: LinearGradient) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: 34, height: 34)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            }

            Text(value)
                .font(.system(.title2, design: .rounded, weight: .black))
                .foregroundStyle(.white)

            Text(label.uppercased())
                .font(.system(size: 9, weight: .heavy))
                .tracking(0.5)
                .foregroundStyle(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(gradient)
        .clipShape(.rect(cornerRadius: 18))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }

    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(EarnedColors.accent)

                Text("Activity")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 4)

            CalendarView(viewModel: viewModel, selectedDate: $selectedDate)
                .padding(16)
                .background(Color(.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 20))
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 10))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.15), value: appeared)
    }

    private var weeklyTrendChart: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(EarnedColors.momentum)

                Text("Last 7 Days")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primary)

                Spacer()

                Text(viewModel.consistencyLabel)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(EarnedColors.accent)
            }

            let data = viewModel.recentWeekData()
            let maxCount = max(data.map(\.count).max() ?? 1, 1)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    chartBar(index: index, item: item, maxCount: maxCount)
                }
            }
            .frame(height: 140)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 20))
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 10))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.25), value: appeared)
    }

    private func chartBar(index: Int, item: (date: Date, count: Int), maxCount: Int) -> some View {
        let barHeight = max(6, CGFloat(item.count) / CGFloat(maxCount) * 100)
        let isTodayDate = isToday(item.date)
        let hasEntry = viewModel.entries[DailyEntry.dateKey(for: item.date)] != nil
        let isComeback = viewModel.entries[DailyEntry.dateKey(for: item.date)]?.isComeback == true

        let barGradient: LinearGradient
        if isTodayDate {
            barGradient = EarnedColors.primaryGradient
        } else if isComeback && item.count > 0 {
            barGradient = LinearGradient(colors: [EarnedColors.momentum.opacity(0.6), EarnedColors.momentum.opacity(0.3)], startPoint: .bottom, endPoint: .top)
        } else if item.count > 0 {
            barGradient = LinearGradient(colors: [EarnedColors.accent.opacity(0.5), EarnedColors.accent.opacity(0.25)], startPoint: .bottom, endPoint: .top)
        } else {
            barGradient = LinearGradient(colors: [Color(.tertiarySystemFill)], startPoint: .bottom, endPoint: .top)
        }

        let labelColor: Color = isTodayDate ? EarnedColors.accent : hasEntry ? .secondary : Color(.tertiaryLabel)

        return Button {
            selectedDate = item.date
        } label: {
            VStack(spacing: 8) {
                if item.count > 0 {
                    Text("\(item.count)")
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundStyle(EarnedColors.accent)
                }

                RoundedRectangle(cornerRadius: 6)
                    .fill(barGradient)
                    .frame(height: barHeight)
                    .animation(reduceMotion ? nil : .spring(response: 0.5).delay(Double(index) * 0.05), value: appeared)

                Text(dayLabel(item.date))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(labelColor)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func dayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(2))
    }

    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}

extension Date: @retroactive Identifiable {
    public var id: TimeInterval { timeIntervalSince1970 }
}
