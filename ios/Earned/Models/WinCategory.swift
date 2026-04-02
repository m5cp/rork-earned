import SwiftUI

nonisolated enum WinCategory: String, Codable, CaseIterable, Sendable, Identifiable {
    case discipline
    case resilience
    case selfKindness = "self_kindness"
    case courage
    case progress
    case habits
    case recovery
    case relationships
    case declaration

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .discipline: "Discipline"
        case .resilience: "Resilience"
        case .selfKindness: "Self-Kindness"
        case .courage: "Courage"
        case .progress: "Progress"
        case .habits: "Habits"
        case .recovery: "Recovery"
        case .relationships: "Relationships"
        case .declaration: "Declaration"
        }
    }

    var icon: String {
        switch self {
        case .discipline: "bolt.fill"
        case .resilience: "flame.fill"
        case .selfKindness: "heart.fill"
        case .courage: "mountain.2.fill"
        case .progress: "arrow.up.right"
        case .habits: "repeat"
        case .recovery: "leaf.fill"
        case .relationships: "person.2.fill"
        case .declaration: "quote.opening"
        }
    }

    var color: Color {
        switch self {
        case .discipline: Color(.systemOrange)
        case .resilience: Color(.systemRed)
        case .selfKindness: Color(.systemPink)
        case .courage: Color(.systemIndigo)
        case .progress: Color(.systemGreen)
        case .habits: Color(.systemTeal)
        case .recovery: Color(.systemMint)
        case .relationships: Color(.systemBlue)
        case .declaration: Color(red: 0.55, green: 0.35, blue: 1.0)
        }
    }
}
