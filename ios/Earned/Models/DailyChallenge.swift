import SwiftUI

nonisolated struct DailyChallenge: Sendable {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let bonusXP: Int
    let targetCategory: WinCategory?

    static func forToday() -> DailyChallenge {
        let weekday = Calendar.current.component(.weekday, from: .now)
        return challenges[(weekday - 1) % challenges.count]
    }

    static let challenges: [DailyChallenge] = [
        DailyChallenge(
            title: "Self-Care Sunday",
            description: "Focus on kindness to yourself today",
            icon: "heart.circle.fill",
            color: Color(.systemPink),
            bonusXP: 2,
            targetCategory: .selfKindness
        ),
        DailyChallenge(
            title: "Mindful Monday",
            description: "Start the week with intention",
            icon: "brain.head.profile.fill",
            color: Color(.systemIndigo),
            bonusXP: 2,
            targetCategory: .discipline
        ),
        DailyChallenge(
            title: "Tough Tuesday",
            description: "Face something you've been avoiding",
            icon: "bolt.circle.fill",
            color: Color(.systemOrange),
            bonusXP: 2,
            targetCategory: .courage
        ),
        DailyChallenge(
            title: "Wellness Wednesday",
            description: "Prioritize recovery and balance",
            icon: "leaf.circle.fill",
            color: Color(.systemMint),
            bonusXP: 2,
            targetCategory: .recovery
        ),
        DailyChallenge(
            title: "Gratitude Thursday",
            description: "Recognize what you've built",
            icon: "star.circle.fill",
            color: Color(.systemYellow),
            bonusXP: 2,
            targetCategory: .progress
        ),
        DailyChallenge(
            title: "Finish Strong Friday",
            description: "End the week with momentum",
            icon: "flame.circle.fill",
            color: Color(.systemRed),
            bonusXP: 2,
            targetCategory: .habits
        ),
        DailyChallenge(
            title: "Connection Saturday",
            description: "Show up for someone today",
            icon: "person.2.circle.fill",
            color: Color(.systemBlue),
            bonusXP: 2,
            targetCategory: .relationships
        ),
    ]
}
