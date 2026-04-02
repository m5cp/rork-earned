import SwiftUI

struct SwipeCardView: View {
    let win: Win
    let dragOffset: CGSize
    var isWide: Bool = false

    private var earnedOpacity: Double {
        max(0, min(1, dragOffset.width / 120))
    }

    private var skippedOpacity: Double {
        max(0, min(1, -dragOffset.width / 120))
    }

    private var cardHeight: CGFloat { isWide ? 480 : 420 }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [win.category.color.opacity(0.2), win.category.color.opacity(0.05)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 48
                        )
                    )
                    .frame(width: 84, height: 84)

                Image(systemName: win.category.icon)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(win.category.color)
                    .symbolEffect(.bounce, value: dragOffset.width > 80)
            }

            Spacer().frame(height: 28)

            Text(win.category.displayName.uppercased())
                .font(.caption2.weight(.heavy))
                .tracking(2.5)
                .foregroundStyle(win.category.color.opacity(0.8))

            Spacer().frame(height: 16)

            Text(win.text)
                .font(isWide ? .title.weight(.heavy) : .title2.weight(.heavy))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 28)
                .minimumScaleFactor(0.8)

            Spacer()

            ZStack {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.body.weight(.bold))
                    Text("EARNED")
                        .font(.caption.weight(.black))
                        .tracking(2)
                }
                .foregroundStyle(EarnedColors.earned)
                .opacity(earnedOpacity)

                HStack(spacing: 8) {
                    Image(systemName: "xmark")
                        .font(.body.weight(.bold))
                    Text("SKIP")
                        .font(.caption.weight(.black))
                        .tracking(2)
                }
                .foregroundStyle(Color(.systemGray3))
                .opacity(skippedOpacity)
            }
            .frame(height: 28)

            Spacer().frame(height: 28)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(.secondarySystemBackground))

                RoundedRectangle(cornerRadius: 28)
                    .fill(earnedGlow)

                RoundedRectangle(cornerRadius: 28)
                    .fill(skipGlow)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28)
                .strokeBorder(borderColor, lineWidth: 1)
        }
        .clipShape(.rect(cornerRadius: 28))
        .shadow(color: .black.opacity(0.08), radius: 20, y: 8)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
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
