import SwiftUI
import RevenueCat

struct SubscriptionView: View {
    var store: StoreViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPackage: Package?
    @State private var isRestoring: Bool = false

    private let features: [(icon: String, title: String, subtitle: String)] = [
        ("star.fill", "Unlimited Check-ins", "Track your wins every day without limits"),
        ("chart.line.uptrend.xyaxis", "Deep Insights", "Weekly momentum, trends, and streaks"),
        ("square.and.arrow.up.fill", "Share Cards", "Beautiful cards to celebrate your wins"),
        ("calendar.badge.checkmark", "Calendar Sync", "See your progress in Apple Calendar"),
        ("bell.badge.fill", "Smart Nudges", "Personalized reminders that respect your time"),
        ("doc.richtext", "Journal & PDF Export", "Reflect and save your journey"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    featuresSection
                    packagesSection
                    footerSection
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .alert("Error", isPresented: .init(
                get: { store.error != nil },
                set: { if !$0 { store.error = nil } }
            )) {
                Button("OK") { store.error = nil }
            } message: {
                Text(store.error ?? "")
            }
            .onChange(of: store.isPremium) { _, isPremium in
                if isPremium { dismiss() }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [EarnedColors.accent.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(EarnedColors.primaryGradient)
            }

            VStack(spacing: 8) {
                Text("Unlock Earned Pro")
                    .font(.title.bold())

                Text("Get the full experience — deeper insights,\nmore tools, and zero limits.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .padding(.top, 24)
        .padding(.bottom, 28)
        .padding(.horizontal, 24)
    }

    private var featuresSection: some View {
        VStack(spacing: 0) {
            ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                HStack(spacing: 16) {
                    Image(systemName: feature.icon)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(EarnedColors.accent)
                        .frame(width: 32, height: 32)
                        .background(EarnedColors.accent.opacity(0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title)
                            .font(.subheadline.weight(.semibold))

                        Text(feature.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundStyle(EarnedColors.earned)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                if index < features.count - 1 {
                    Divider()
                        .padding(.leading, 68)
                }
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal, 16)
    }

    private var packagesSection: some View {
        VStack(spacing: 12) {
            if store.isLoading {
                ProgressView()
                    .padding(.vertical, 40)
            } else if let current = store.offerings?.current {
                let sorted = sortedPackages(current.availablePackages)

                ForEach(sorted, id: \.identifier) { package in
                    PackageCard(
                        package: package,
                        isSelected: selectedPackage?.identifier == package.identifier,
                        isBestValue: package.identifier == "$annual"
                    ) {
                        withAnimation(.spring(duration: 0.25)) {
                            selectedPackage = package
                        }
                    }
                }
                .onAppear {
                    if selectedPackage == nil {
                        selectedPackage = sorted.first(where: { $0.identifier == "$annual" }) ?? sorted.first
                    }
                }

                Button {
                    guard let pkg = selectedPackage else { return }
                    Task { await store.purchase(package: pkg) }
                } label: {
                    Group {
                        if store.isPurchasing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Continue")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(EarnedColors.accent)
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 14))
                }
                .disabled(selectedPackage == nil || store.isPurchasing)
                .padding(.top, 4)
            } else {
                ContentUnavailableView("Unable to Load Plans", systemImage: "exclamationmark.triangle", description: Text("Check your connection and try again."))
                    .padding(.vertical, 20)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
    }

    private var footerSection: some View {
        VStack(spacing: 12) {
            Button {
                isRestoring = true
                Task {
                    await store.restore()
                    isRestoring = false
                }
            } label: {
                if isRestoring {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text("Restore Purchases")
                        .font(.footnote.weight(.medium))
                }
            }
            .foregroundStyle(.secondary)

            VStack(spacing: 4) {
                Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions in your App Store account settings.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)

                HStack(spacing: 16) {
                    NavigationLink("Privacy Policy") {
                        PrivacyPolicyView()
                    }
                    NavigationLink("Terms of Use") {
                        TermsOfUseView()
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 40)
    }

    private func sortedPackages(_ packages: [Package]) -> [Package] {
        let order: [String] = ["$monthly", "$annual", "$lifetime"]
        return packages.sorted { a, b in
            let ai = order.firstIndex(of: a.identifier) ?? 99
            let bi = order.firstIndex(of: b.identifier) ?? 99
            return ai < bi
        }
    }
}

struct PackageCard: View {
    let package: Package
    let isSelected: Bool
    let isBestValue: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? EarnedColors.accent : Color(.separator), lineWidth: isSelected ? 6 : 2)
                        .frame(width: 24, height: 24)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(displayName)
                            .font(.subheadline.weight(.semibold))

                        if isBestValue {
                            Text("BEST VALUE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(EarnedColors.earned)
                                .clipShape(Capsule())
                        }
                    }

                    Text(priceDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(package.storeProduct.localizedPriceString)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(isSelected ? EarnedColors.accent : .primary)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isSelected ? EarnedColors.accent : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var displayName: String {
        switch package.identifier {
        case "$monthly": return "Monthly"
        case "$annual": return "Yearly"
        case "$lifetime": return "Lifetime"
        default: return package.storeProduct.localizedTitle
        }
    }

    private var priceDescription: String {
        switch package.identifier {
        case "$monthly":
            return "Billed monthly"
        case "$annual":
            return "Save ~58% vs monthly"
        case "$lifetime":
            return "One-time purchase"
        default:
            return ""
        }
    }
}
