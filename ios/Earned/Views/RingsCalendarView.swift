import SwiftUI

struct RingsCalendarView: View {
    let viewModel: EarnedViewModel
    @Binding var selectedDate: IdentifiableDate?
    @State private var displayedMonth: Date = .now

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    private let weekdayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(spacing: 14) {
            monthNavigator
            weekdayHeader
            daysGrid
        }
    }

    private var monthNavigator: some View {
        HStack {
            Button {
                withAnimation(.snappy(duration: 0.3)) { shiftMonth(by: -1) }
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
                withAnimation(.snappy(duration: 0.3)) { shiftMonth(by: 1) }
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
        HStack(spacing: 6) {
            ForEach(Array(weekdayLabels.enumerated()), id: \.offset) { _, label in
                Text(label)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var daysGrid: some View {
        let dates = viewModel.calendarDates(for: displayedMonth)
        let offset = viewModel.weekdayOffset(for: displayedMonth)

        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(0..<offset, id: \.self) { _ in
                Color.clear.frame(height: 44)
            }

            ForEach(dates, id: \.timeIntervalSince1970) { date in
                dayCell(for: date)
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let calendar = Calendar.current
        let isFuture = date > .now && !calendar.isDateInToday(date)
        let isToday = calendar.isDateInToday(date)
        let rings = isFuture ? ReflectionRings.empty : viewModel.rings(for: date)
        let day = calendar.component(.day, from: date)

        return Button {
            guard !isFuture else { return }
            selectedDate = IdentifiableDate(date: date)
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if isToday {
                        Circle()
                            .strokeBorder(EarnedColors.accent.opacity(0.5), lineWidth: 1.2)
                            .padding(-2)
                    }
                    MiniReflectionRings(rings: rings, lineWidth: 3, spacing: 1.5)
                        .frame(width: 30, height: 30)
                        .opacity(isFuture ? 0.25 : 1)
                }
                .frame(width: 34, height: 34)

                Text("\(day)")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(isFuture ? Color(.tertiaryLabel) : .secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
        .accessibilityLabel(accessibilityLabel(for: date, rings: rings, isFuture: isFuture))
    }

    private func accessibilityLabel(for date: Date, rings: ReflectionRings, isFuture: Bool) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateStr = formatter.string(from: date)
        if isFuture { return dateStr }
        return "\(dateStr), \(rings.closedCount) of 3 rings closed"
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
