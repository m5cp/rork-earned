import SwiftUI
import WidgetKit

@Observable
@MainActor
class EarnedViewModel {
    var entries: [String: DailyEntry] = [:]
    var todayWins: [Win] = []
    var currentCardIndex: Int = 0
    var checkInComplete: Bool = false
    var showSummary: Bool = false
    var showComeback: Bool = false
    var comebackDismissed: Bool = false

    private let storageKey = "earned_entries"
    private let lastOpenDateKey = "last_open_date"
    private let cardCount = 5

    var todayKey: String { DailyEntry.dateKey() }

    var todayEntry: DailyEntry? { entries[todayKey] }

    var hasCheckedInToday: Bool { todayEntry != nil && checkInComplete }

    var todayEarnedWins: [Win] {
        earnedWins(for: todayKey)
    }

    var todayEarnedCount: Int { todayEntry?.earnedCount ?? 0 }

    var isLastCard: Bool {
        currentCardIndex >= todayWins.count - 1
    }

    var currentWin: Win? {
        guard currentCardIndex < todayWins.count else { return nil }
        return todayWins[currentCardIndex]
    }

    var progress: Double {
        guard !todayWins.isEmpty else { return 0 }
        return Double(currentCardIndex) / Double(todayWins.count)
    }

    var currentStreak: Int {
        var streak = 0
        var date = Date.now
        let calendar = Calendar.current

        while true {
            let key = DailyEntry.dateKey(for: date)
            if let entry = entries[key], !entry.earnedWinIDs.isEmpty {
                streak += 1
                guard let previous = calendar.date(byAdding: .day, value: -1, to: date) else { break }
                date = previous
            } else if key == todayKey {
                guard let previous = calendar.date(byAdding: .day, value: -1, to: date) else { break }
                date = previous
            } else {
                break
            }
        }
        return streak
    }

    var consistencyLabel: String {
        let activeDays = daysActiveInLast(7)
        if activeDays >= 7 { return "Every day this week" }
        if activeDays >= 5 { return "\(activeDays) of 7 days" }
        if activeDays >= 3 { return "\(activeDays) of 7 days" }
        if activeDays >= 1 { return "Back again" }
        return "Start today"
    }

    var consistencyRatio: String {
        let active = daysActiveInLast(7)
        return "\(active)/7"
    }

    func daysActiveInLast(_ days: Int) -> Int {
        let calendar = Calendar.current
        var count = 0
        for i in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -i, to: .now) {
                let key = DailyEntry.dateKey(for: date)
                if let entry = entries[key], !entry.earnedWinIDs.isEmpty {
                    count += 1
                }
            }
        }
        return count
    }

    var trend: TrendDirection {
        let calendar = Calendar.current
        var thisWeek = 0
        var lastWeek = 0

        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: .now) {
                let key = DailyEntry.dateKey(for: date)
                thisWeek += entries[key]?.earnedCount ?? 0
            }
            if let date = calendar.date(byAdding: .day, value: -(i + 7), to: .now) {
                let key = DailyEntry.dateKey(for: date)
                lastWeek += entries[key]?.earnedCount ?? 0
            }
        }

        if lastWeek == 0 && thisWeek == 0 { return .steady }
        if lastWeek == 0 { return .up }
        if thisWeek > lastWeek { return .up }
        if thisWeek < lastWeek { return .down }
        return .steady
    }

    var trendLabel: String {
        switch trend {
        case .up: "Trending up"
        case .down: "Room to grow"
        case .steady: "Holding steady"
        }
    }

    var showSayItOutLoud: Bool = false
    var summaryDismissed: Bool = false

    var sayItOutLoudStatement: String {
        let raw = SayItOutLoudLibrary.statement(for: todayEarnedWins)
        if raw.hasSuffix(".") || raw.hasSuffix("!") {
            return raw
        }
        return raw + "."
    }

    var longestStreak: Int {
        let sortedKeys = entries.keys.sorted()
        var longest = 0
        var current = 0
        var lastDate: Date?
        let calendar = Calendar.current

        for key in sortedKeys {
            guard let entry = entries[key], !entry.earnedWinIDs.isEmpty,
                  let date = DailyEntry.date(from: key) else {
                current = 0
                lastDate = nil
                continue
            }

            if let last = lastDate,
               let expected = calendar.date(byAdding: .day, value: 1, to: last),
               calendar.isDate(date, inSameDayAs: expected) {
                current += 1
            } else {
                current = 1
            }

            longest = max(longest, current)
            lastDate = date
        }

        return longest
    }

    var totalDaysCheckedIn: Int {
        entries.values.filter { !$0.earnedWinIDs.isEmpty }.count
    }

    var totalWinsEarned: Int {
        entries.values.reduce(0) { $0 + $1.earnedCount }
    }

    var totalComebacks: Int {
        entries.values.filter(\.isComeback).count
    }

    var currentLevel: Int {
        MilestoneLibrary.level(for: totalWinsEarned)
    }

    var levelTitle: String {
        MilestoneLibrary.levelTitle(for: currentLevel)
    }

    var levelProgress: Double {
        MilestoneLibrary.progressToNextLevel(totalWins: totalWinsEarned)
    }

    var winsToNextLevel: Int {
        MilestoneLibrary.winsToNextLevel(totalWins: totalWinsEarned)
    }

    var unlockedMilestones: [Milestone] {
        MilestoneLibrary.unlockedMilestones(
            longestStreak: longestStreak,
            totalWins: totalWinsEarned,
            totalDays: totalDaysCheckedIn,
            comebacks: totalComebacks
        )
    }

    var nextMilestones: [Milestone] {
        MilestoneLibrary.nextMilestones(
            longestStreak: longestStreak,
            totalWins: totalWinsEarned,
            totalDays: totalDaysCheckedIn,
            comebacks: totalComebacks
        )
    }

    var weeklyEarnedCount: Int {
        let calendar = Calendar.current
        var total = 0
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: .now) {
                let key = DailyEntry.dateKey(for: date)
                total += entries[key]?.earnedCount ?? 0
            }
        }
        return total
    }

    var monthlyEarnedCount: Int {
        let calendar = Calendar.current
        var total = 0
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: .now) {
                let key = DailyEntry.dateKey(for: date)
                total += entries[key]?.earnedCount ?? 0
            }
        }
        return total
    }

    var weeklyMomentum: WeeklyMomentum {
        WeeklyMomentumService.generateMomentum(from: entries)
    }

    var weeklyMomentumHeadline: String {
        WeeklyMomentumService.headline(for: weeklyMomentum)
    }

    var weeklyMomentumSubheadline: String {
        WeeklyMomentumService.subheadline(for: weeklyMomentum)
    }

    func refreshWeeklyNotification() {
        let momentum = weeklyMomentum
        if UserDefaults.standard.bool(forKey: "weeklyMomentumEnabled") {
            WeeklyMomentumService.scheduleWeeklyNotification(for: momentum)
        }
    }

    func refreshNudgeIfNeeded() {
        guard UserDefaults.standard.bool(forKey: "nudgeEnabled") else { return }

        let nudgeTime: Date
        if let saved = UserDefaults.standard.object(forKey: "nudgeTime") as? Date {
            nudgeTime = saved
        } else {
            var components = DateComponents()
            components.hour = 9
            components.minute = 0
            nudgeTime = Calendar.current.date(from: components) ?? .now
        }

        let frequency: DailyNudgeService.NudgeFrequency
        if let rawFreq = UserDefaults.standard.string(forKey: "nudgeFrequency"),
           let freq = DailyNudgeService.NudgeFrequency(rawValue: rawFreq) {
            frequency = freq
        } else {
            frequency = .daily
        }

        DailyNudgeService.scheduleNudges(
            time: nudgeTime,
            frequency: frequency,
            hasCompletedToday: hasCheckedInToday
        )
    }

    var monthWeekData: [(weekLabel: String, count: Int)] {
        let calendar = Calendar.current
        var weeks: [(weekLabel: String, count: Int)] = []
        for w in (0..<4).reversed() {
            var total = 0
            for d in 0..<7 {
                let daysAgo = w * 7 + d
                if let date = calendar.date(byAdding: .day, value: -daysAgo, to: .now) {
                    let key = DailyEntry.dateKey(for: date)
                    total += entries[key]?.earnedCount ?? 0
                }
            }
            let label = w == 0 ? "This" : "\(w)w"
            weeks.append((weekLabel: label, count: total))
        }
        return weeks
    }

    var topCategory: WinCategory? {
        var counts: [WinCategory: Int] = [:]
        let allWins = WinLibrary.all

        for entry in entries.values {
            for winID in entry.earnedWinIDs {
                if let win = allWins.first(where: { $0.id == winID }) {
                    counts[win.category, default: 0] += 1
                }
            }
        }

        return counts.max(by: { $0.value < $1.value })?.key
    }

    func recentWeekData() -> [(date: Date, count: Int)] {
        let calendar = Calendar.current
        var result: [(date: Date, count: Int)] = []

        for i in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: .now) else { continue }
            let key = DailyEntry.dateKey(for: date)
            let count = entries[key]?.earnedCount ?? 0
            result.append((date: date, count: count))
        }

        return result
    }

    var isReturningAfterMissedDay: Bool {
        let calendar = Calendar.current
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: .now) else { return false }
        let yesterdayKey = DailyEntry.dateKey(for: yesterday)
        let hasYesterdayEntry = entries[yesterdayKey] != nil && !(entries[yesterdayKey]?.earnedWinIDs.isEmpty ?? true)

        if hasYesterdayEntry { return false }

        let hasAnyPastEntry = entries.values.contains { entry in
            guard let entryDate = DailyEntry.date(from: entry.date) else { return false }
            return !calendar.isDateInToday(entryDate) && !entry.earnedWinIDs.isEmpty
        }

        return hasAnyPastEntry
    }

    init() {
        loadEntries()
        prepareTodayWins()

        if let entry = entries[todayKey] {
            let totalResponded = entry.earnedWinIDs.count + entry.skippedWinIDs.count
            let comebackAlreadyCounted = entry.earnedWinIDs.contains(Win.comebackID)
            let adjustedCount = comebackAlreadyCounted ? totalResponded - 1 : totalResponded
            checkInComplete = adjustedCount >= cardCount
            if checkInComplete {
                showSummary = true
            }
        }

        if !checkInComplete && isReturningAfterMissedDay && todayEntry?.isComeback != true {
            showComeback = true
        }

        syncWidgetData()
    }

    func prepareTodayWins() {
        todayWins = Array(WinLibrary.dailySet(count: cardCount))
        currentCardIndex = 0
    }

    func earnWin(_ win: Win) {
        var entry = entries[todayKey] ?? DailyEntry(date: todayKey, earnedWinIDs: [], skippedWinIDs: [])
        if !entry.earnedWinIDs.contains(win.id) {
            entry.earnedWinIDs.append(win.id)
        }
        entries[todayKey] = entry
        advanceCard()
    }

    func skipWin(_ win: Win) {
        var entry = entries[todayKey] ?? DailyEntry(date: todayKey, earnedWinIDs: [], skippedWinIDs: [])
        if !entry.skippedWinIDs.contains(win.id) {
            entry.skippedWinIDs.append(win.id)
        }
        entries[todayKey] = entry
        advanceCard()
    }

    private func advanceCard() {
        if currentCardIndex < todayWins.count - 1 {
            currentCardIndex += 1
            updateLiveActivity()
        } else {
            checkInComplete = true
            showSummary = true
            saveEntries()
            refreshNudgeIfNeeded()
            syncToCalendarIfNeeded()
            syncWidgetData()
            CheckInActivityService.endSession()
        }
    }

    func logComeback() {
        var entry = entries[todayKey] ?? DailyEntry(date: todayKey, earnedWinIDs: [], skippedWinIDs: [])
        entry.isComeback = true
        if !entry.earnedWinIDs.contains(Win.comebackID) {
            entry.earnedWinIDs.append(Win.comebackID)
        }
        entries[todayKey] = entry
        saveEntries()
        showComeback = false
        comebackDismissed = true
    }

    func resetToday() {
        entries.removeValue(forKey: todayKey)
        checkInComplete = false
        showSummary = false
        summaryDismissed = false
        prepareTodayWins()
        saveEntries()
    }

    func startOver() {
        resetToday()
    }

    func dismissSummary() {
        showSummary = false
        summaryDismissed = true
    }

    func openSayItOutLoud() {
        showSayItOutLoud = true
    }

    func completeSayItOutLoud() {
        let statement = sayItOutLoudStatement
        var entry = entries[todayKey] ?? DailyEntry(date: todayKey, earnedWinIDs: [], skippedWinIDs: [])
        entry.sayItOutLoudStatement = statement
        entry.sayItOutLoudCompleted = true
        if !entry.earnedWinIDs.contains(Win.sayItOutLoudID) {
            entry.earnedWinIDs.append(Win.sayItOutLoudID)
        }
        entries[todayKey] = entry
        saveEntries()
        showSayItOutLoud = false
    }

    func dismissSayItOutLoud() {
        showSayItOutLoud = false
    }

    func saveJournalNote(for dateKey: String, note: String) {
        var entry = entries[dateKey] ?? DailyEntry(date: dateKey, earnedWinIDs: [], skippedWinIDs: [])
        entry.journalNote = note.isEmpty ? nil : note
        entries[dateKey] = entry
        saveEntries()
    }

    func earnedWins(for dateKey: String) -> [Win] {
        guard let entry = entries[dateKey] else { return [] }
        let allWins = WinLibrary.all
        return entry.earnedWinIDs.compactMap { winID in
            if winID == Win.sayItOutLoudID {
                let statement = entry.sayItOutLoudStatement ?? "Said it out loud."
                return Win.sayItOutLoud(statement: statement)
            }
            if winID == Win.comebackID {
                return Win.comeback()
            }
            return allWins.first { $0.id == winID }
        }
    }

    func calendarDates(for month: Date) -> [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return []
        }
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)
        }
    }

    func weekdayOffset(for month: Date) -> Int {
        let calendar = Calendar.current
        guard let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else { return 0 }
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        return (weekday - calendar.firstWeekday + 7) % 7
    }

    func monthLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    var maxDailyEarned: Int {
        entries.values.map(\.earnedCount).max() ?? 1
    }

    private func loadEntries() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([String: DailyEntry].self, from: data) else { return }
        entries = decoded
    }

    func saveEntries() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    func syncWidgetData() {
        let latestWin = todayEarnedWins.last
        SharedDataService.writeWidgetData(
            todayWin: latestWin?.text,
            streak: currentStreak,
            earnedCount: todayEarnedCount,
            consistency: consistencyRatio,
            topCategory: topCategory?.displayName,
            trend: trendLabel
        )
    }

    func startLiveActivity() {
        guard !todayWins.isEmpty else { return }
        let firstWin = todayWins[0]
        CheckInActivityService.startSession(
            totalCards: todayWins.count,
            firstWinText: firstWin.text,
            firstCategory: firstWin.category.displayName
        )
    }

    private func updateLiveActivity() {
        let earned = todayEarnedCount
        let currentText = currentWin?.text ?? ""
        let currentCat = currentWin?.category.displayName ?? ""
        CheckInActivityService.updateProgress(
            earnedCount: earned,
            totalCards: todayWins.count,
            currentWinText: currentText,
            currentCategory: currentCat
        )
    }

    func syncToCalendarIfNeeded() {
        guard let entry = todayEntry else { return }
        let wins = todayEarnedWins
        CalendarSyncService.shared.syncSession(
            entry: entry,
            earnedWins: wins,
            streak: currentStreak,
            trend: trendLabel
        )
    }
}
