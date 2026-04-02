import SwiftUI

struct CalendarView: View {
    let viewModel: EarnedViewModel
    @Binding var selectedDate: Date?
    @State private var displayedMonth: Date = .now

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(spacing: 16) {
            monthNavigator
            weekdayHeader
            daysGrid
        }
    }

    private var monthNavigator: some View {
        HStack {
            Button {
                withAnimation(.snappy(duration: 0.3)) {
                    shiftMonth(by: -1)
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(EarnedColors.accent)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }

            Spacer()

            Text(viewModel.monthLabel(for: displayedMonth))
                .font(.headline.weight(.bold))

            Spacer()

            Button {
                withAnimation(.snappy(duration: 0.3)) {
                    shiftMonth(by: 1)
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(canGoForward ? EarnedColors.accent : Color(.tertiaryLabel))
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
            .disabled(!canGoForward)
        }
        .padding(.horizontal, 4)
    }

    private var weekdayHeader: some View {
        HStack(spacing: 4) {
            ForEach(Array(weekdayLabels.enumerated()), id: \.offset) { _, label in
                Text(label)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(EarnedColors.accent.opacity(0.5))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var daysGrid: some View {
        let dates = viewModel.calendarDates(for: displayedMonth)
        let offset = viewModel.weekdayOffset(for: displayedMonth)

        return LazyVGrid(columns: columns, spacing: 6) {
            ForEach(0..<offset, id: \.self) { _ in
                Color.clear.frame(height: 40)
            }

            ForEach(dates, id: \.timeIntervalSince1970) { date in
                dayCell(for: date)
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let calendar = Calendar.current
        let key = DailyEntry.dateKey(for: date)
        let entry = viewModel.entries[key]
        let earnedCount = entry?.earnedCount ?? 0
        let isToday = calendar.isDateInToday(date)
        let isFuture = date > .now && !isToday
        let isSelected = selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false
        let hasActivity = earnedCount > 0
        let isComeback = entry?.isComeback == true
        let isPast = !isFuture && !isToday
        let isMissedDay = isPast && !hasActivity
        let maxEarned = max(viewModel.maxDailyEarned, 1)

        return Button {
            guard !isFuture else { return }
            selectedDate = date
        } label: {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(EarnedColors.accent)
                        .frame(width: 38, height: 38)
                } else if isComeback && hasActivity {
                    Circle()
                        .fill(EarnedColors.momentum.opacity(0.3))
                        .frame(width: 38, height: 38)
                } else if hasActivity {
                    Circle()
                        .fill(EarnedColors.accent.opacity(0.15 + Double(earnedCount) / Double(maxEarned) * 0.55))
                        .frame(width: 38, height: 38)
                } else if isToday {
                    Circle()
                        .strokeBorder(EarnedColors.accent.opacity(0.4), lineWidth: 1.5)
                        .frame(width: 38, height: 38)
                } else if isMissedDay {
                    Circle()
                        .fill(Color(.quaternarySystemFill))
                        .frame(width: 38, height: 38)
                }

                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(.callout, design: .rounded, weight: hasActivity ? .bold : .regular))
                    .foregroundStyle(
                        isSelected ? .white :
                        isFuture ? Color(.quaternaryLabel) :
                        hasActivity ? EarnedColors.accent :
                        isToday ? .primary :
                        isMissedDay ? Color(.tertiaryLabel) :
                        .secondary
                    )
            }
            .frame(height: 40)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
        .accessibilityLabel(accessibilityLabel(for: date, earned: earnedCount, isComeback: isComeback))
    }

    private func accessibilityLabel(for date: Date, earned: Int, isComeback: Bool) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateStr = formatter.string(from: date)
        if isComeback {
            return "\(dateStr), came back, \(earned) wins earned"
        }
        if earned > 0 {
            return "\(dateStr), \(earned) wins earned"
        }
        return dateStr
    }

    private func shiftMonth(by value: Int) {
        guard let newMonth = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        displayedMonth = newMonth
    }

    private var canGoForward: Bool {
        let calendar = Calendar.current
        let currentMonth = calendar.dateComponents([.year, .month], from: .now)
        let displayed = calendar.dateComponents([.year, .month], from: displayedMonth)
        if let current = calendar.date(from: currentMonth), let disp = calendar.date(from: displayed) {
            return disp < current
        }
        return false
    }
}
