import SwiftUI

nonisolated struct Milestone: Identifiable, Sendable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    let requirement: Int
    let type: MilestoneType

    nonisolated enum MilestoneType: String, Sendable {
        case streak
        case totalWins
        case totalDays
        case comeback
        case category
    }
}

nonisolated enum MilestoneLibrary: Sendable {
    static let all: [Milestone] = [
        Milestone(id: "streak_3", title: "Getting Started", description: "3-day streak", icon: "flame.fill", color: Color(.systemOrange), requirement: 3, type: .streak),
        Milestone(id: "streak_7", title: "One Week Strong", description: "7-day streak", icon: "flame.fill", color: Color(.systemOrange), requirement: 7, type: .streak),
        Milestone(id: "streak_14", title: "Fortnight Force", description: "14-day streak", icon: "flame.fill", color: Color(.systemRed), requirement: 14, type: .streak),
        Milestone(id: "streak_30", title: "Monthly Machine", description: "30-day streak", icon: "flame.fill", color: Color(.systemRed), requirement: 30, type: .streak),
        Milestone(id: "streak_60", title: "Unstoppable", description: "60-day streak", icon: "flame.fill", color: Color(.systemPurple), requirement: 60, type: .streak),
        Milestone(id: "streak_100", title: "Century Club", description: "100-day streak", icon: "flame.fill", color: Color(.systemYellow), requirement: 100, type: .streak),

        Milestone(id: "wins_5", title: "First Handful", description: "Earn 5 wins", icon: "star.fill", color: Color(.systemTeal), requirement: 5, type: .totalWins),
        Milestone(id: "wins_25", title: "Quarter Century", description: "Earn 25 wins", icon: "star.fill", color: Color(.systemBlue), requirement: 25, type: .totalWins),
        Milestone(id: "wins_50", title: "Half Century", description: "Earn 50 wins", icon: "star.fill", color: Color(.systemBlue), requirement: 50, type: .totalWins),
        Milestone(id: "wins_100", title: "Triple Digits", description: "Earn 100 wins", icon: "star.fill", color: Color(.systemIndigo), requirement: 100, type: .totalWins),
        Milestone(id: "wins_250", title: "Powerhouse", description: "Earn 250 wins", icon: "star.fill", color: Color(.systemPurple), requirement: 250, type: .totalWins),
        Milestone(id: "wins_500", title: "Legend", description: "Earn 500 wins", icon: "star.fill", color: Color(.systemYellow), requirement: 500, type: .totalWins),

        Milestone(id: "days_3", title: "Day Tripper", description: "Check in 3 days", icon: "checkmark.circle.fill", color: Color(.systemGreen), requirement: 3, type: .totalDays),
        Milestone(id: "days_7", title: "Week Warrior", description: "Check in 7 days", icon: "checkmark.circle.fill", color: Color(.systemGreen), requirement: 7, type: .totalDays),
        Milestone(id: "days_30", title: "Monthly Regular", description: "Check in 30 days", icon: "checkmark.circle.fill", color: Color(.systemMint), requirement: 30, type: .totalDays),
        Milestone(id: "days_100", title: "Centurion", description: "Check in 100 days", icon: "checkmark.circle.fill", color: Color(.systemCyan), requirement: 100, type: .totalDays),

        Milestone(id: "comeback_1", title: "Bounced Back", description: "First comeback", icon: "arrow.counterclockwise", color: Color(.systemPink), requirement: 1, type: .comeback),
        Milestone(id: "comeback_5", title: "Resilient", description: "5 comebacks", icon: "arrow.counterclockwise", color: Color(.systemPink), requirement: 5, type: .comeback),
        Milestone(id: "comeback_10", title: "Unbreakable", description: "10 comebacks", icon: "arrow.counterclockwise", color: Color(.systemRed), requirement: 10, type: .comeback),
    ]

    static func unlockedMilestones(longestStreak: Int, totalWins: Int, totalDays: Int, comebacks: Int) -> [Milestone] {
        all.filter { milestone in
            switch milestone.type {
            case .streak: longestStreak >= milestone.requirement
            case .totalWins: totalWins >= milestone.requirement
            case .totalDays: totalDays >= milestone.requirement
            case .comeback: comebacks >= milestone.requirement
            case .category: false
            }
        }
    }

    static func nextMilestones(longestStreak: Int, totalWins: Int, totalDays: Int, comebacks: Int) -> [Milestone] {
        let grouped = Dictionary(grouping: all, by: \.type)
        var next: [Milestone] = []

        for (type, milestones) in grouped {
            let sorted = milestones.sorted { $0.requirement < $1.requirement }
            let current: Int = switch type {
            case .streak: longestStreak
            case .totalWins: totalWins
            case .totalDays: totalDays
            case .comeback: comebacks
            case .category: 0
            }
            if let nextMilestone = sorted.first(where: { $0.requirement > current }) {
                next.append(nextMilestone)
            }
        }
        return next.sorted { $0.requirement - currentValue(for: $0.type, streak: longestStreak, wins: totalWins, days: totalDays, comebacks: comebacks) < $1.requirement - currentValue(for: $1.type, streak: longestStreak, wins: totalWins, days: totalDays, comebacks: comebacks) }
    }

    private static func currentValue(for type: Milestone.MilestoneType, streak: Int, wins: Int, days: Int, comebacks: Int) -> Int {
        switch type {
        case .streak: streak
        case .totalWins: wins
        case .totalDays: days
        case .comeback: comebacks
        case .category: 0
        }
    }

    static func level(for totalWins: Int) -> Int {
        if totalWins >= 500 { return 10 }
        if totalWins >= 350 { return 9 }
        if totalWins >= 250 { return 8 }
        if totalWins >= 175 { return 7 }
        if totalWins >= 120 { return 6 }
        if totalWins >= 75 { return 5 }
        if totalWins >= 45 { return 4 }
        if totalWins >= 25 { return 3 }
        if totalWins >= 10 { return 2 }
        if totalWins >= 3 { return 1 }
        return 0
    }

    static func levelTitle(for level: Int) -> String {
        switch level {
        case 0: "Newcomer"
        case 1: "Starter"
        case 2: "Builder"
        case 3: "Achiever"
        case 4: "Contender"
        case 5: "Warrior"
        case 6: "Champion"
        case 7: "Elite"
        case 8: "Master"
        case 9: "Grandmaster"
        case 10: "Legend"
        default: "Legend"
        }
    }

    static let levelThresholds: [Int] = [0, 3, 10, 25, 45, 75, 120, 175, 250, 350, 500]

    static func progressToNextLevel(totalWins: Int) -> Double {
        let currentLevel = level(for: totalWins)
        guard currentLevel < 10 else { return 1.0 }
        let currentThreshold = levelThresholds[currentLevel]
        let nextThreshold = levelThresholds[currentLevel + 1]
        let range = nextThreshold - currentThreshold
        guard range > 0 else { return 1.0 }
        return Double(totalWins - currentThreshold) / Double(range)
    }

    static func winsToNextLevel(totalWins: Int) -> Int {
        let currentLevel = level(for: totalWins)
        guard currentLevel < 10 else { return 0 }
        return levelThresholds[currentLevel + 1] - totalWins
    }
}
