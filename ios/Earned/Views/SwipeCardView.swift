import SwiftUI

nonisolated enum SwipeCardStyle: Sendable {
    case standard
    case immersive
}

struct RaisedIfImmersive: ViewModifier {
    let isImmersive: Bool
    func body(content: Content) -> some View {
        if isImmersive {
            content.shadow(color: .black.opacity(0.5), radius: 2, y: 2)
        } else {
            content
        }
    }
}

struct SwipeCardView: View {
    let win: Win
    let dragOffset: CGSize
    var isWide: Bool = false
    var style: SwipeCardStyle = .standard

    private var earnedOpacity: Double {
        max(0, min(1, dragOffset.width / 120))
    }

    private var skippedOpacity: Double {
        max(0, min(1, -dragOffset.width / 120))
    }

    private var cardHeight: CGFloat { isWide ? 480 : 420 }

    private var isImmersive: Bool { style == .immersive }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                win.category.color.opacity(isImmersive ? 0.35 : 0.2),
                                win.category.color.opacity(isImmersive ? 0.1 : 0.05)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: isImmersive ? 52 : 48
                        )
                    )
                    .frame(width: isImmersive ? 92 : 84, height: isImmersive ? 92 : 84)

                Image(systemName: win.category.icon)
                    .font(.system(size: isImmersive ? 34 : 30, weight: .bold))
                    .foregroundStyle(win.category.color)
                    .symbolEffect(.bounce, value: dragOffset.width > 80)
            }

            Spacer().frame(height: 28)

            Text(win.category.displayName.uppercased())
                .font(.caption2.weight(.heavy))
                .tracking(2.5)
                .foregroundStyle(win.category.color)
                .raisedText()

            Spacer().frame(height: 16)

            Text(win.text)
                .font(isWide ? .title.weight(.heavy) : .title2.weight(.heavy))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 28)
                .minimumScaleFactor(0.8)
                .foregroundStyle(isImmersive ? .white : .primary)
                .modifier(RaisedIfImmersive(isImmersive: isImmersive))

            Spacer()

            ZStack {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.body.weight(.bold))

                    Text("YES")
                        .font(.caption.weight(.black))
                        .tracking(2)
                }
                .foregroundStyle(EarnedColors.earned)
                .opacity(earnedOpacity)

                HStack(spacing: 8) {
                    Image(systemName: "circle")
                        .font(.body.weight(.bold))
                    Text("NOT TODAY")
                        .font(.caption.weight(.black))
                        .tracking(2)
                }
                .foregroundStyle(isImmersive ? .white.opacity(0.7) : Color(.systemGray2))
                .opacity(skippedOpacity)
            }
            .frame(height: 28)

            Spacer().frame(height: 28)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .background {
            if isImmersive {
                immersiveBackground
            } else {
                standardBackground
            }
        }
        .overlay {
            if isImmersive {
                immersiveBorder
            } else {
                RoundedRectangle(cornerRadius: 28)
                    .strokeBorder(borderColor, lineWidth: 1)
            }
        }
        .clipShape(.rect(cornerRadius: 28))
        .shadow(
            color: isImmersive ? EarnedColors.accent.opacity(0.15) : .black.opacity(0.08),
            radius: isImmersive ? 30 : 20,
            y: isImmersive ? 12 : 8
        )
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    private var immersiveBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.08, green: 0.08, blue: 0.2),
                            Color(red: 0.06, green: 0.06, blue: 0.16),
                            Color(red: 0.04, green: 0.04, blue: 0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 28)
                .fill(
                    RadialGradient(
                        colors: [
                            win.category.color.opacity(0.08),
                            Color.clear
                        ],
                        center: .top,
                        startRadius: 0,
                        endRadius: 250
                    )
                )

            RoundedRectangle(cornerRadius: 28)
                .fill(EarnedColors.earned.opacity(earnedOpacity * 0.12))

            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(skippedOpacity * 0.04))
        }
    }

    private var immersiveBorder: some View {
        RoundedRectangle(cornerRadius: 28)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        earnedOpacity > 0.15
                            ? EarnedColors.earned.opacity(earnedOpacity * 0.6)
                            : Color.white.opacity(0.12),
                        Color.white.opacity(0.04)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }

    private var standardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(.secondarySystemBackground))

            RoundedRectangle(cornerRadius: 28)
                .fill(earnedGlow)

            RoundedRectangle(cornerRadius: 28)
                .fill(skipGlow)
        }
    }

    private var earnedGlow: some ShapeStyle {
        EarnedColors.earned.opacity(earnedOpacity * 0.08)
    }

    private var skipGlow: some ShapeStyle {
        Color(.systemGray4).opacity(skippedOpacity * 0.06)
    }

    private var borderColor: Color {
        if earnedOpacity > 0.15 {
            return EarnedColors.earned.opacity(earnedOpacity * 0.5)
        } else if skippedOpacity > 0.15 {
            return Color(.systemGray3).opacity(skippedOpacity * 0.35)
        }
        return Color(.separator).opacity(0.12)
    }
}
