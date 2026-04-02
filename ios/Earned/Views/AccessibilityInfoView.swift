import SwiftUI

struct AccessibilityInfoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                    .padding(.bottom, 4)

                sectionCard(
                    icon: "hand.draw.fill",
                    iconColor: EarnedColors.accent,
                    title: "VoiceOver Support",
                    content: "MVM Earned is built with VoiceOver in mind. All interactive elements are labeled so screen readers can describe actions, progress, and card content clearly."
                )

                sectionCard(
                    icon: "textformat.size",
                    iconColor: EarnedColors.earned,
                    title: "Dynamic Type",
                    content: "The app supports Dynamic Type, adapting text sizes to your system preferences. Adjust text size in Settings → Accessibility → Display & Text Size for the best reading experience."
                )

                sectionCard(
                    icon: "circle.lefthalf.filled",
                    iconColor: EarnedColors.momentum,
                    title: "Dark Mode",
                    content: "Full Dark Mode support ensures comfortable viewing in low-light environments. Switch between Light, Dark, or System themes in the app's Appearance settings."
                )

                sectionCard(
                    icon: "hand.tap.fill",
                    iconColor: EarnedColors.streak,
                    title: "Touch Targets",
                    content: "All buttons and interactive elements meet Apple's minimum 44×44 point touch target guidelines, making the app easier to use for everyone."
                )

                sectionCard(
                    icon: "paintpalette.fill",
                    iconColor: EarnedColors.strength,
                    title: "Color & Contrast",
                    content: "MVM Earned uses high-contrast text and meaningful color choices. Important information is never conveyed by color alone — icons and labels always accompany visual indicators."
                )

                sectionCard(
                    icon: "arrow.left.arrow.right",
                    iconColor: .secondary,
                    title: "Reduce Motion",
                    content: "The app respects the Reduce Motion setting. When enabled, animations are minimized to provide a comfortable experience for users sensitive to motion."
                )

                sectionCard(
                    icon: "envelope.fill",
                    iconColor: EarnedColors.accent,
                    title: "Feedback",
                    content: "We're committed to improving accessibility. If you encounter any barriers or have suggestions, please reach out to us at contact@m5capital.org."
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Accessibility")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(EarnedColors.momentum.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: "accessibility")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(EarnedColors.momentum)
            }

            VStack(spacing: 6) {
                Text("Accessibility")
                    .font(.title2.weight(.bold))
                Text("Built for everyone. Here's how MVM Earned supports accessibility.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private func sectionCard(icon: String, iconColor: Color, title: String, content: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(content)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14, style: .continuous))
    }
}
