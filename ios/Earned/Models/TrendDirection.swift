import Foundation

nonisolated enum TrendDirection: Sendable {
    case up, down, steady

    var icon: String {
        switch self {
        case .up: "arrow.up.right"
        case .down: "arrow.down.right"
        case .steady: "arrow.right"
        }
    }
}
