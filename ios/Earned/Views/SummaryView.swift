import SwiftUI

struct SummaryView: View {
    let viewModel: EarnedViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared: Bool = false
    @State private var showShareSheet: Bool = false

    private var earnedWins: [Win] {
        viewModel.todayEarnedWins
    }

    private var headline: String {
        let count = earnedWins.count
        if count == 0 { return "Tomorrow is yours." }
        if count == 1 { return "You showed up." }
        if count <= 3 { return "You earned today." }
        return "You owned today."
    }

    private var shareHeadline: String {
        let count = earnedWins.count
        if count == 0 { return "Tomorrow is mine." }
        if count == 1 { return "I showed up." }
        if count <= 3 { return "I earned today." }
        return "I owned today."
    }

    private var subheadline: String {
        let count = earnedWins.count
        if count == 0 { return "You can always say it tomorrow." }
        if count == 1 { return "That still counts." }
        return "\(count) wins earned today"
    }

    private var isWide: Bool { horizontalSizeClass == .regular }
    private var contentMaxWidth: CGFloat { isWide ? 520 : .infinity }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    heroSection
                        .padding(.top, isWide ? 56 : 40)
                        .padding(.bottom, 32)

                    statsRow
                        .padding(.horizontal, 24)
                        .padding(.bottom, 28)

                    if !earnedWins.isEmpty {
                        earnedSection
                            .padding(.horizontal, 24)
                            .padding(.bottom, 28)
                    }

                    actionButtons
                        .padding(.horizontal, 24)
                        .padding(.bottom, 48)
                }
                .frame(maxWidth: contentMaxWidth)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            if reduceMotion { appeared = true }
            else { withAnimation(.easeOut(duration: 0.6)) { appeared = true } }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareCardSheet(
                wins: earnedWins,
                affirmation: shareHeadline,
                earnedCount: viewModel.todayEarnedCount,
                streak: viewModel.currentStreak,
                trendLabel: viewModel.trendLabel
            )
        }
        .sensoryFeedback(.success, trigger: appeared)
    }

    private var heroSection: some View {
        VStack(spacing: 24) {
            ZStack {
                if earnedWins.isEmpty {
                    Circle()
                        .fill(Color(.tertiarySystemFill))
                        .frame(width: 88, height: 88)

                    Image(systemName: "moon.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(.tertiary)
                } else {
                    Circle()
                        .fill(EarnedColors.earnedGradient)
                        .frame(width: 88, height: 88)
                        .shadow(color: EarnedColors.earned.opacity(0.3), radius: 16, y: 4)

                    Text("\(earnedWins.count)")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
            .scaleEffect(appeared ? 1 : 0.7)
            .opacity(appeared ? 1 : 0)
            .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.7), value: appeared)

            VStack(spacing: 8) {
                Text(headline)
                    .font(.system(size: 30, weight: .heavy))
                    .multilineTextAlignment(.center)

                Text(subheadline)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(EarnedColors.accent)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: reduceMotion ? 0 : (appeared ? 0 : 14))
            .animation(reduceMotion ? nil : .easeOut(duration: 0.5).delay(0.15), value: appeared)
        }
        .accessibilityElement(children: .combine)
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(
                value: viewModel.consistencyRatio,
                label: "This Week"
            )

            divider

            statItem(
                value: "\(earnedWins.count)",
                label: "Earned"
            )

            divider

            statItem(
                value: trendSymbol,
                label: "Momentum"
            )
        }
        .padding(.vertical, 18)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 10))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.25), value: appeared)
        .accessibilityElement(children: .combine)
    }

    private var trendSymbol: String {
        switch viewModel.trend {
        case .up: "↑"
        case .down: "→"
        case .steady: "→"
        }
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(.headline, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label.uppercased())
                .font(.system(size: 10, weight: .heavy))
                .tracking(0.8)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color(.separator).opacity(0.3))
            .frame(width: 0.5, height: 36)
    }

    private var earnedSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("WHAT YOU EARNED")
                .font(.caption2.weight(.heavy))
                .tracking(1.5)
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                .opacity(appeared ? 1 : 0)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.3), value: appeared)

            VStack(spacing: 0) {
                ForEach(Array(earnedWins.enumerated()), id: \.element.id) { index, win in
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(win.category.color.opacity(0.12))
                                .frame(width: 38, height: 38)

                            Image(systemName: win.category.icon)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(win.category.color)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(win.text)
                                .font(.subheadline.weight(.semibold))

                            Text(win.category.displayName)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(win.category.color.opacity(0.7))
                        }

                        Spacer()

                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(EarnedColors.earned)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: reduceMotion ? 0 : (appeared ? 0 : 8))
                    .animation(reduceMotion ? nil : .spring(response: 0.4).delay(0.35 + Double(index) * 0.06), value: appeared)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Earned: \(win.text)")

                    if index < earnedWins.count - 1 {
                        Divider().padding(.leading, 68)
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private var sayItOutLoudCompleted: Bool {
        viewModel.todayEntry?.sayItOutLoudCompleted == true
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if !sayItOutLoudCompleted {
                Button {
                    viewModel.openSayItOutLoud()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "quote.opening")
                            .font(.body.weight(.medium))
                        Text("Say It Out Loud")
                            .font(.body.weight(.bold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(EarnedColors.primaryGradient)
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 16))
                }
                .sensoryFeedback(.impact(flexibility: .soft), trigger: viewModel.showSayItOutLoud)
            }

            if !earnedWins.isEmpty {
                Button {
                    showShareSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.body.weight(.medium))
                        Text("Share Card")
                            .font(.body.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(.secondarySystemBackground))
                    .foregroundStyle(.primary)
                    .clipShape(.rect(cornerRadius: 16))
                }
            }

            Button {
                viewModel.startOver()
            } label: {
                Text("Redo")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.tertiary)
            }
            .padding(.top, 4)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 12))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.5), value: appeared)
        .sensoryFeedback(.success, trigger: sayItOutLoudCompleted)
    }
}
