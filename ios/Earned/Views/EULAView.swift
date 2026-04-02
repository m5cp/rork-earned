import SwiftUI

struct EULAView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    header
                        .padding(.bottom, 4)

                    sectionCard(
                        icon: "doc.text.fill",
                        iconColor: EarnedColors.accent,
                        title: "Licensed Application",
                        content: "The app licensed to you under this End User License Agreement (\"EULA\") is MVM Earned (the \"Licensed Application\"), made available through the Apple App Store."
                    )

                    sectionCard(
                        icon: "checkmark.seal.fill",
                        iconColor: EarnedColors.earned,
                        title: "Scope of License",
                        content: "This license granted to you is limited to a non-transferable license to use the Licensed Application on any Apple-branded products that you own or control as permitted by the Usage Rules set forth in the Apple Media Services Terms and Conditions."
                    )

                    sectionCard(
                        icon: "wrench.and.screwdriver.fill",
                        iconColor: EarnedColors.momentum,
                        title: "Maintenance and Support",
                        content: "The developer is solely responsible for providing maintenance and support services for the Licensed Application. Apple has no obligation to furnish any maintenance and support services with respect to the Licensed Application."
                    )

                    sectionCard(
                        icon: "exclamationmark.shield.fill",
                        iconColor: EarnedColors.streak,
                        title: "Warranty",
                        content: "The developer is solely responsible for any product warranties, whether express or implied by law. In the event of any failure of the Licensed Application to conform to any applicable warranty, you may notify Apple, and Apple will refund the purchase price (if any). Apple has no other warranty obligation with respect to the Licensed Application."
                    )

                    sectionCard(
                        icon: "person.crop.circle.badge.checkmark",
                        iconColor: EarnedColors.accent,
                        title: "Product Claims",
                        content: "The developer, not Apple, is responsible for addressing any claims relating to the Licensed Application or your possession and/or use of the Licensed Application, including but not limited to: (i) product liability claims; (ii) any claim that the Licensed Application fails to conform to any applicable legal or regulatory requirement; and (iii) claims arising under consumer protection, privacy, or similar legislation."
                    )

                    sectionCard(
                        icon: "text.book.closed.fill",
                        iconColor: EarnedColors.strength,
                        title: "Intellectual Property",
                        content: "The developer, not Apple, is responsible for the investigation, defense, settlement, and discharge of any third-party intellectual property infringement claim related to the Licensed Application."
                    )

                    sectionCard(
                        icon: "globe",
                        iconColor: .secondary,
                        title: "Legal Compliance",
                        content: "You represent and warrant that (i) you are not located in a country that is subject to a U.S. Government embargo or designated as a \"terrorist supporting\" country; and (ii) you are not listed on any U.S. Government list of prohibited or restricted parties."
                    )

                    sectionCard(
                        icon: "apple.logo",
                        iconColor: .primary,
                        title: "Third-Party Beneficiary",
                        content: "Apple and its subsidiaries are third-party beneficiaries of this EULA. Upon your acceptance, Apple will have the right (and will be deemed to have accepted the right) to enforce this EULA against you as a third-party beneficiary thereof."
                    )

                    sectionCard(
                        icon: "envelope.fill",
                        iconColor: EarnedColors.momentum,
                        title: "Contact",
                        content: "If you have questions about this license agreement, contact us at contact@m5capital.org."
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
            .navigationTitle("Apple EULA")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(EarnedColors.accent.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: "doc.plaintext.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(EarnedColors.accent)
            }

            VStack(spacing: 6) {
                Text("End User License Agreement")
                    .font(.title2.weight(.bold))
                Text("Apple's standard EULA for licensed applications.")
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
