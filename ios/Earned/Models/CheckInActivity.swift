import ActivityKit
import Foundation

nonisolated struct CheckInActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Sendable {
        var earnedCount: Int
        var totalCards: Int
        var currentWinText: String
        var currentCategory: String
    }

    var sessionDate: String
}
