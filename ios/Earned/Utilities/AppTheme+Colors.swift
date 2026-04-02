import SwiftUI

enum EarnedColors {
    static let accent = Color(red: 0.22, green: 0.48, blue: 1.0)
    static let accentGlow = Color(red: 0.35, green: 0.58, blue: 1.0)
    static let accentBright = Color(red: 0.36, green: 0.62, blue: 1.0)

    static let earned = Color(red: 0.12, green: 0.72, blue: 0.44)
    static let earnedBright = Color(red: 0.2, green: 0.82, blue: 0.54)
    static let earnedSoft = Color(red: 0.12, green: 0.72, blue: 0.44).opacity(0.15)

    static let streak = Color(red: 1.0, green: 0.52, blue: 0.12)
    static let streakSoft = Color(red: 1.0, green: 0.52, blue: 0.12).opacity(0.15)

    static let momentum = Color(red: 0.5, green: 0.32, blue: 1.0)
    static let momentumBright = Color(red: 0.62, green: 0.45, blue: 1.0)
    static let momentumSoft = Color(red: 0.5, green: 0.32, blue: 1.0).opacity(0.12)

    static let strength = Color(red: 0.92, green: 0.24, blue: 0.34)
    static let strengthSoft = Color(red: 0.92, green: 0.24, blue: 0.34).opacity(0.12)

    static let cardBackground = Color(.secondarySystemBackground)

    static let deepNavy = Color(red: 0.04, green: 0.05, blue: 0.14)
    static let deepIndigo = Color(red: 0.08, green: 0.06, blue: 0.22)
    static let deepViolet = Color(red: 0.12, green: 0.06, blue: 0.26)

    static let immersiveLabel = Color.white.opacity(0.75)
    static let immersiveSublabel = Color.white.opacity(0.6)

    static let primaryGradient = LinearGradient(
        colors: [accent, momentum],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let earnedGradient = LinearGradient(
        colors: [earned, Color(red: 0.08, green: 0.62, blue: 0.52)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let streakGradient = LinearGradient(
        colors: [streak, Color(red: 1.0, green: 0.38, blue: 0.18)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let immersiveGradient = LinearGradient(
        colors: [
            deepNavy,
            deepIndigo,
            deepViolet,
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func intensityColor(for count: Int, max: Int) -> Color {
        guard max > 0 else { return .clear }
        let ratio = Double(count) / Double(max)
        return accent.opacity(0.2 + ratio * 0.8)
    }
}

extension View {
    func raisedText(radius: CGFloat = 1, y: CGFloat = 1) -> some View {
        self
            .shadow(color: .black.opacity(0.5), radius: radius, y: y)
    }

    func raisedHeadline() -> some View {
        self
            .shadow(color: .black.opacity(0.6), radius: 2, y: 2)
            .shadow(color: .black.opacity(0.2), radius: 6, y: 4)
    }
}
