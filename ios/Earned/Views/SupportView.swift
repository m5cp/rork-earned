import SwiftUI

struct SupportView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                    .padding(.bottom, 4)

                sectionCard(
                    icon: "envelope.fill",
                    iconColor: EarnedColors.accent,
                    title: "App Support",
                    content: "For questions about how MVM Earned works, feature requests, feedback, or any issues with the app experience, reach out to our team directly.",
                    action: AnyView(
                        Button {
                            if let url = URL(string: "mailto:contact@m5capital.org") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text("contact@m5capital.org")
                                    .font(.subheadline.weight(.semibold))
                                Image(systemName: "arrow.up.right")
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundStyle(EarnedColors.accent)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(EarnedColors.accent.opacity(0.12))
                            .clipShape(.capsule)
                        }
                    )
                )

                sectionCard(
                    icon: "apple.logo",
                    iconColor: .primary,
                    title: "Managed by Apple",
                    content: "Some things are handled directly by Apple through your Apple ID account. For the following, go to your device settings or contact Apple Support:",
                    action: AnyView(
                        VStack(alignment: .leading, spacing: 10) {
                            appleItem(icon: "creditcard.fill", text: "Subscriptions & billing")
                            appleItem(icon: "arrow.uturn.left.circle.fill", text: "Refunds & purchase history")
                            appleItem(icon: "person.crop.circle.fill", text: "Apple ID & account issues")
                            appleItem(icon: "arrow.down.circle.fill", text: "Download & installation problems")

                            Button {
                                if let url = URL(string: "https://support.apple.com") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Text("Apple Support")
                                        .font(.subheadline.weight(.semibold))
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption.weight(.semibold))
                                }
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color(.tertiarySystemFill))
                                .clipShape(.capsule)
                            }
                            .padding(.top, 4)
                        }
                    )
                )

                sectionCard(
                    icon: "questionmark.circle.fill",
                    iconColor: EarnedColors.earned,
                    title: "Common Questions",
                    content: nil,
                    action: AnyView(
                        VStack(alignment: .leading, spacing: 12) {
                            faqItem(
                                question: "Where is my data stored?",
                                answer: "All your data stays on your device. Nothing is uploaded or shared."
                            )
                            Divider()
                            faqItem(
                                question: "How do I cancel a subscription?",
                                answer: "Go to Settings → your name → Subscriptions on your device. Apple manages all subscriptions."
                            )
                            Divider()
                            faqItem(
                                question: "Can I recover lost data?",
                                answer: "Since data is stored locally, it cannot be recovered if the app is deleted. We recommend using the share card to save your progress."
                            )
                            Divider()
                            faqItem(
                                question: "How do I request a refund?",
                                answer: "Refunds are handled by Apple. Visit reportaproblem.apple.com or contact Apple Support."
                            )
                        }
                    )
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(EarnedColors.accent.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: "lifepreserver.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(EarnedColors.accent)
            }

            VStack(spacing: 6) {
                Text("How Can We Help?")
                    .font(.title2.weight(.bold))
                Text("Find answers or get in touch with the right team.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private func sectionCard(icon: String, iconColor: Color, title: String, content: String?, action: AnyView) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(iconColor)
                }

                Text(title)
                    .font(.headline)
            }

            if let content {
                Text(content)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            action
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14, style: .continuous))
    }

    private func appleItem(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 22)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }

    private func faqItem(question: String, answer: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(question)
                .font(.subheadline.weight(.semibold))
            Text(answer)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
