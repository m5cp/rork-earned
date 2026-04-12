import Foundation

nonisolated struct StreakShield: Codable, Sendable {
    var freeShieldsUsedThisWeek: Int
    var lastWeekReset: String
    var shieldActiveDates: [String]

    static let freeShieldsPerWeek = 1
    static let proShieldsPerWeek = 3

    init() {
        self.freeShieldsUsedThisWeek = 0
        self.lastWeekReset = DailyEntry.dateKey()
        self.shieldActiveDates = []
    }

    var weekResetNeeded: Bool {
        guard let lastReset = DailyEntry.date(from: lastWeekReset) else { return true }
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: .now) ?? .now
        return lastReset < weekAgo
    }
}
