import Foundation

nonisolated struct DailyEntry: Codable, Sendable, Identifiable {
    let date: String
    var earnedWinIDs: [String]
    var skippedWinIDs: [String]
    var sayItOutLoudStatement: String?
    var sayItOutLoudCompleted: Bool
    var isComeback: Bool
    var journalNote: String?
    var weeklyReflection: String?
    var mood: Mood?
    var aiJournalEntry: String?
    var aiJournalGeneratedAt: Date?
    var aiReflectionCount: Int = 0

    var id: String { date }

    var earnedCount: Int { earnedWinIDs.count }

    init(date: String, earnedWinIDs: [String], skippedWinIDs: [String], sayItOutLoudStatement: String? = nil, sayItOutLoudCompleted: Bool = false, isComeback: Bool = false, weeklyReflection: String? = nil, mood: Mood? = nil, aiJournalEntry: String? = nil, aiJournalGeneratedAt: Date? = nil, aiReflectionCount: Int = 0) {
        self.date = date
        self.earnedWinIDs = earnedWinIDs
        self.skippedWinIDs = skippedWinIDs
        self.sayItOutLoudStatement = sayItOutLoudStatement
        self.sayItOutLoudCompleted = sayItOutLoudCompleted
        self.isComeback = isComeback
        self.weeklyReflection = weeklyReflection
        self.mood = mood
        self.aiJournalEntry = aiJournalEntry
        self.aiJournalGeneratedAt = aiJournalGeneratedAt
        self.aiReflectionCount = aiReflectionCount
    }

    static func dateKey(for date: Date = .now) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static func date(from key: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: key)
    }
}
