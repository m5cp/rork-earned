import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                    .padding(.bottom, 4)

                sectionCard(
                    icon: "iphone.and.arrow.forward.inward",
                    iconColor: EarnedColors.accent,
                    title: "Device-Only Storage",
                    content: "All your data lives on your device. Check-in history, earned entries, streaks, and personal statements never leave your phone."
                )

                sectionCard(
                    icon: "eye.slash.fill",
                    iconColor: EarnedColors.momentum,
                    title: "Zero Data Collection",
                    content: "No analytics, no tracking pixels, no third-party SDKs. Your usage is completely private and invisible to us."
                )

                sectionCard(
                    icon: "camera.fill",
                    iconColor: EarnedColors.earned,
                    title: "Camera & Photos",
                    content: "Camera and photo library access is used solely for creating share cards. Everything is processed on-device and never uploaded."
                )

                sectionCard(
                    icon: "person.crop.circle.badge.minus",
                    iconColor: EarnedColors.streak,
                    title: "No Account Required",
                    content: "No sign-up, no email, no phone number. MVM Earned works without any personal information."
                )

                sectionCard(
                    icon: "bell.badge.fill",
                    iconColor: EarnedColors.accent,
                    title: "Local Notifications",
                    content: "Reminders are scheduled locally on your device. No notification data is sent to external servers."
                )

                sectionCard(
                    icon: "trash.fill",
                    iconColor: EarnedColors.strength,
                    title: "Data Deletion",
                    content: "Delete all your data anytime from Settings. Reset All Data permanently removes everything from your device."
                )

                sectionCard(
                    icon: "wifi.slash",
                    iconColor: EarnedColors.momentum,
                    title: "Fully Offline",
                    content: "No third-party services, advertising networks, or analytics platforms. The app functions entirely offline."
                )

                sectionCard(
                    icon: "arrow.triangle.2.circlepath",
                    iconColor: .secondary,
                    title: "Policy Updates",
                    content: "Changes to this policy will be reflected in future app updates. Continued use constitutes acceptance."
                )

                sectionCard(
                    icon: "envelope.fill",
                    iconColor: .secondary,
                    title: "Contact",
                    content: "Questions about this policy? Reach out through the App Store listing."
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
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(EarnedColors.earned.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(EarnedColors.earned)
            }

            VStack(spacing: 6) {
                Text("Your Privacy Matters")
                    .font(.title2.weight(.bold))
                Text("Everything stays on your device. Always.")
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
