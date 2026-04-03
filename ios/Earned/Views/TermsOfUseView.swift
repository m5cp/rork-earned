import SwiftUI

struct TermsOfUseView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                    .padding(.bottom, 4)

                sectionCard(
                    icon: "checkmark.seal.fill",
                    iconColor: EarnedColors.accent,
                    title: "Acceptance of Terms",
                    content: "By downloading, installing, or using MVM Earned, you agree to these Terms of Use. If you do not agree, please do not use the app."
                )

                sectionCard(
                    icon: "sparkles",
                    iconColor: EarnedColors.momentum,
                    title: "Description of Service",
                    content: "MVM Earned is a personal development tool designed to help you recognize and reinforce daily progress through guided check-ins, affirmation prompts, and progress tracking stored locally on your device."
                )

                sectionCard(
                    icon: "person.fill",
                    iconColor: EarnedColors.earned,
                    title: "Personal Use",
                    content: "MVM Earned is intended for personal, non-commercial use. You may not redistribute, reverse-engineer, or modify the app or its content."
                )

                sectionCard(
                    icon: "text.book.closed.fill",
                    iconColor: EarnedColors.streak,
                    title: "Intellectual Property",
                    content: "All content within MVM Earned, including text, prompts, statements, and design elements, is the intellectual property of MVM Earned. Reproduction or distribution requires written permission."
                )

                sectionCard(
                    icon: "heart.text.clipboard.fill",
                    iconColor: EarnedColors.strength,
                    title: "User Responsibility",
                    content: "MVM Earned is a self-reflection and personal growth tool. It is not a substitute for professional mental health care, therapy, or medical advice. If you are experiencing a crisis, please contact a qualified professional or emergency service."
                )

                sectionCard(
                    icon: "exclamationmark.shield.fill",
                    iconColor: .secondary,
                    title: "No Warranties",
                    content: "MVM Earned is provided as-is without warranties of any kind, express or implied. We do not guarantee that the app will be error-free or uninterrupted."
                )

                sectionCard(
                    icon: "scale.3d",
                    iconColor: .secondary,
                    title: "Limitation of Liability",
                    content: "To the fullest extent permitted by law, MVM Earned and its creators shall not be liable for any indirect, incidental, or consequential damages arising from your use of the app."
                )

                sectionCard(
                    icon: "lock.fill",
                    iconColor: EarnedColors.accent,
                    title: "Data & Privacy",
                    content: "Your use of MVM Earned is also governed by our Privacy Policy. All data is stored locally on your device and is not collected or transmitted."
                )

                sectionCard(
                    icon: "rectangle.on.rectangle.angled",
                    iconColor: EarnedColors.streak,
                    title: "Widgets, Live Activities & Siri",
                    content: "MVM Earned offers Home Screen widgets, Lock Screen widgets, Live Activities, and Siri Shortcuts. These features use on-device App Groups to share data between the app and system extensions. No data is transmitted externally. Siri processes voice commands locally."
                )

                sectionCard(
                    icon: "arrow.triangle.2.circlepath",
                    iconColor: EarnedColors.momentum,
                    title: "Modifications",
                    content: "We reserve the right to update these Terms of Use at any time. Changes will be reflected in future app updates. Continued use after changes constitutes acceptance."
                )

                sectionCard(
                    icon: "xmark.circle.fill",
                    iconColor: .secondary,
                    title: "Termination",
                    content: "You may stop using MVM Earned at any time by deleting the app. Upon deletion, all locally stored data is permanently removed."
                )

                sectionCard(
                    icon: "envelope.fill",
                    iconColor: .secondary,
                    title: "Contact",
                    content: "Questions about these terms? Reach out through the App Store listing."
                )

                Text("Last updated: April 2026")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Terms of Use")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(EarnedColors.accent.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(EarnedColors.accent)
            }

            VStack(spacing: 6) {
                Text("Terms of Use")
                    .font(.title2.weight(.bold))
                Text("The terms that govern your use of MVM Earned.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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
