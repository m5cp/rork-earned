import Foundation

nonisolated enum PhotoFilter: String, CaseIterable, Identifiable, Sendable {
    case natural
    case warm
    case cool
    case sharp
    case fade
    case mono

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .natural: "Natural"
        case .warm: "Warm"
        case .cool: "Cool"
        case .sharp: "Sharp"
        case .fade: "Fade"
        case .mono: "Mono"
        }
    }

    var icon: String {
        switch self {
        case .natural: "circle"
        case .warm: "sun.max"
        case .cool: "snowflake"
        case .sharp: "diamond"
        case .fade: "aqi.medium"
        case .mono: "circle.lefthalf.filled"
        }
    }
}
