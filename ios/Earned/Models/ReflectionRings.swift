import SwiftUI

nonisolated struct ReflectionRings: Sendable {
    let checkIn: Double
    let reflect: Double
    let mood: Double

    static let empty = ReflectionRings(checkIn: 0, reflect: 0, mood: 0)

    var closedCount: Int {
        [checkIn, reflect, mood].reduce(0) { $0 + ($1 >= 1.0 ? 1 : 0) }
    }

    var allClosed: Bool { closedCount == 3 }
}

nonisolated enum RingKind: String, CaseIterable, Sendable, Identifiable {
    case checkIn
    case reflect
    case mood

    var id: String { rawValue }

    var title: String {
        switch self {
        case .checkIn: "Check-In"
        case .reflect: "Reflect"
        case .mood: "Mood"
        }
    }

    var iconName: String {
        switch self {
        case .checkIn: "checkmark.circle.fill"
        case .reflect: "text.book.closed.fill"
        case .mood: "face.smiling.fill"
        }
    }

    @MainActor
    var gradient: LinearGradient {
        switch self {
        case .checkIn:
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.22, blue: 0.32), Color(red: 1.0, green: 0.52, blue: 0.12)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .reflect:
            return LinearGradient(
                colors: [Color(red: 0.66, green: 1.0, blue: 0.28), Color(red: 0.12, green: 0.82, blue: 0.44)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .mood:
            return LinearGradient(
                colors: [Color(red: 0.3, green: 0.88, blue: 1.0), Color(red: 0.22, green: 0.48, blue: 1.0)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }

    @MainActor
    var solidColor: Color {
        switch self {
        case .checkIn: Color(red: 1.0, green: 0.3, blue: 0.25)
        case .reflect: Color(red: 0.25, green: 0.88, blue: 0.45)
        case .mood: Color(red: 0.28, green: 0.7, blue: 1.0)
        }
    }
}
