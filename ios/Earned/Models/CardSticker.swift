import CoreGraphics
import Foundation

nonisolated struct CardSticker: Identifiable, Sendable, Equatable {
    let id: String
    let symbol: String
    var offset: CGSize

    init(symbol: String, offset: CGSize = .zero) {
        self.id = UUID().uuidString
        self.symbol = symbol
        self.offset = offset
    }

    static let available: [String] = [
        "flame.fill",
        "star.fill",
        "bolt.fill",
        "heart.fill",
        "crown.fill",
        "trophy.fill",
        "medal.fill",
        "target",
        "mountain.2.fill",
        "flag.fill",
        "hands.clap.fill",
        "hand.thumbsup.fill",
        "sparkles",
        "checkmark.seal.fill",
        "arrow.up.right",
        "brain.head.profile.fill"
    ]
}
