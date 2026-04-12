import SwiftUI

nonisolated enum Mood: String, Codable, CaseIterable, Sendable, Identifiable {
    case great
    case good
    case okay
    case low
    case rough

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .great: "😄"
        case .good: "🙂"
        case .okay: "😐"
        case .low: "😔"
        case .rough: "😞"
        }
    }

    var label: String {
        switch self {
        case .great: "Great"
        case .good: "Good"
        case .okay: "Okay"
        case .low: "Low"
        case .rough: "Rough"
        }
    }

    var color: Color {
        switch self {
        case .great: Color(.systemGreen)
        case .good: Color(.systemTeal)
        case .okay: Color(.systemYellow)
        case .low: Color(.systemOrange)
        case .rough: Color(.systemRed)
        }
    }

    var numericValue: Int {
        switch self {
        case .great: 5
        case .good: 4
        case .okay: 3
        case .low: 2
        case .rough: 1
        }
    }
}
