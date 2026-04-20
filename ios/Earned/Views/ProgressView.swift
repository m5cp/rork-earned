import SwiftUI

struct EarnedProgressView: View {
    let viewModel: EarnedViewModel
    var gameCenter: GameCenterService = GameCenterService.shared
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared: Bool = false
    @State private var selectedDate: IdentifiableDate?
    @State private var ringDetailDate: IdentifiableDate?

    private var isWide: Bool { horizontalSizeClass == .regular }

    private var hasAnyData: Bool {
        !viewModel.entries.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if hasAnyData {
                    VStack(spacing: 24) {
                        ringsHero
                        ringsCalendarSection
                        aiQuickActions
                        moodTrendSection
                        WeeklyMomentumCardView(viewModel: viewModel)

                        NavigationLink {
                            WeeklyInsightView(viewModel: viewModel)
                        } label: {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(EarnedColors.accent.opacity(0.15))
                                        .frame(width: 36, height: 36)

                                    Image(systemName: "brain.head.profile.fill")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(EarnedColors.accent)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Weekly AI Insight")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(.primary)
                                    Text("See patterns in your progress")
                                        .font(.caption2.weight(.medium))
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(14)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(.rect(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)

                        calendarSection
                        weeklyTrendChart
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                    .frame(maxWidth: isWide ? 720 : .infinity)
                    .frame(maxWidth: .infinity)
                } else {
                    emptyState
                }
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Progress")
            .onAppear {
                if reduceMotion { appeared = true }
                else { withAnimation(.easeOut(duration: 0.5)) { appeared = true } }
            }
            .sheet(item: $selectedDate) { item in
                DayDetailView(viewModel: viewModel, date: item.date)
            }
            .sheet(item: $ringDetailDate) { item in
                RingDetailView(viewModel: viewModel, date: item.date)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 80)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [EarnedColors.accent.opacity(0.2), EarnedColors.accent.opacity(0.05)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(EarnedColors.accent.opacity(0.6))
            }
            .scaleEffect(appeared ? 1 : 0.7)
            .opacity(appeared ? 1 : 0)
            .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.7), value: appeared)

            VStack(spacing: 10) {
                Text("Your Progress Starts Here")
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)

                Text("Complete your first check-in to start\ntracking your wins and streaks.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: reduceMotion ? 0 : (appeared ? 0 : 10))
            .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.1), value: appeared)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
    }

    private var ringsHero: some View {
        let rings = viewModel.todayRings
        let today = Date.now
        let dateFormatter: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "EEEE, MMM d"
            return f
        }()

        return Button {
            ringDetailDate = IdentifiableDate(date: today)
        } label: {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TODAY")
                            .font(.caption2.weight(.heavy))
                            .tracking(1.2)
                            .foregroundStyle(.secondary)
                        Text(dateFormatter.string(from: today))
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                    if rings.allClosed {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.caption.weight(.bold))
                            Text("Perfect day")
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.3, blue: 0.25), Color(red: 0.5, green: 0.32, blue: 1.0)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                    } else {
                        Text("\(rings.closedCount)/3")
                            .font(.system(.subheadline, design: .rounded, weight: .heavy))
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 20) {
                    ReflectionRingsView(rings: rings, lineWidth: 16, spacing: 5)
                        .frame(width: 140, height: 140)

                    VStack(spacing: 10) {
                        ringLegend(.checkIn, progress: rings.checkIn)
                        ringLegend(.reflect, progress: rings.reflect)
                        ringLegend(.mood, progress: rings.mood)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                HStack(spacing: 4) {
                    Text("Tap for details")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.tertiary)
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(18)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 22))
        }
        .buttonStyle(.plain)
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 10))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4), value: appeared)
        .sensoryFeedback(.success, trigger: rings.allClosed)
    }

    private func ringLegend(_ kind: RingKind, progress: Double) -> some View {
        let percent = Int(round(progress * 100))
        return HStack(spacing: 8) {
            Circle()
                .fill(kind.gradient)
                .frame(width: 10, height: 10)
            Text(kind.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
            Spacer(minLength: 4)
            Text("\(percent)%")
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(progress >= 1.0 ? kind.solidColor : .secondary)
                .monospacedDigit()
        }
    }

    private var ringsCalendarSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "circle.circle.fill")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(EarnedColors.streak)

                Text("Rings")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 4)

            RingsCalendarView(viewModel: viewModel, selectedDate: $ringDetailDate)
                .padding(16)
                .background(Color(.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 20))
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 10))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.1), value: appeared)
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
                .foregroundStyle(.white.opacity(0.9))
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

        let labelColor: Color = isTodayDate ? EarnedColors.accent : hasEntry ? .primary : Color(.secondaryLabel)

        return Button {
            selectedDate = IdentifiableDate(date: item.date)
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

    private var aiQuickActions: some View {
        HStack(spacing: 12) {
            NavigationLink {
                CoachChatView(earnedViewModel: viewModel)
            } label: {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(EarnedColors.momentum.opacity(0.15))
                            .frame(width: 36, height: 36)

                        Image(systemName: "bubble.left.and.text.bubble.right.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(EarnedColors.momentum)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("AI Coach")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.primary)
                        Text("Chat about your progress")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.tertiary)
                }
                .padding(14)
                .background(Color(.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 16))
            }
            .buttonStyle(.plain)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 10))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.05), value: appeared)
    }

    private var moodTrendSection: some View {
        let recentMoods = viewModel.moodHistory.prefix(7)

        return Group {
            if !recentMoods.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "face.smiling")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(EarnedColors.streak)

                        Text("Mood")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.primary)

                        Spacer()

                        if let avg = viewModel.averageMood {
                            Text(String(format: "%.1f", avg) + " avg")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 4)

                    HStack(spacing: 8) {
                        let moodItems = Array(recentMoods.reversed())
                        ForEach(Array(moodItems.enumerated()), id: \.element.date) { _, item in
                            VStack(spacing: 6) {
                                Text(item.mood.emoji)
                                    .font(.title3)

                                if let date = DailyEntry.date(from: item.date) {
                                    Text(date, format: .dateTime.weekday(.narrow))
                                        .font(.caption2.weight(.medium))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(16)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(.rect(cornerRadius: 20))
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: reduceMotion ? 0 : (appeared ? 0 : 10))
                .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.1), value: appeared)
            }
        }
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

nonisolated struct IdentifiableDate: Identifiable, Sendable {
    let date: Date
    var id: TimeInterval { date.timeIntervalSince1970 }
}
