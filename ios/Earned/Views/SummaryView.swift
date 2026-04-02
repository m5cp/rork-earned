import SwiftUI

struct SummaryView: View {
    let viewModel: EarnedViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var iconBounce: Int = 0

    private var earnedWins: [Win] {
        viewModel.todayEarnedWins
    }

    private var isComeback: Bool {
        viewModel.todayEntry?.isComeback == true
    }

    private var sayItOutLoudCompleted: Bool {
        viewModel.todayEntry?.sayItOutLoudCompleted == true
    }

    private var headline: String {
        let count = earnedWins.count
        if count == 0 { return "You added to today." }
        if isComeback && count == 1 { return "You came back." }
        if count == 1 { return "You showed up." }
        if sayItOutLoudCompleted && count >= 3 { return "You followed through." }
        if count <= 2 { return "That counts." }
        if count <= 4 { return "You made progress." }
        return "You owned today."
    }

    private var shareHeadline: String {
        let count = earnedWins.count
        if count == 0 { return "I added to today." }
        if isComeback && count == 1 { return "I came back." }
        if count == 1 { return "I showed up." }
        if sayItOutLoudCompleted && count >= 3 { return "I followed through." }
        if count <= 2 { return "That counts." }
        if count <= 4 { return "I made progress." }
        return "I owned today."
    }

    private var isWide: Bool { horizontalSizeClass == .regular }
    private var contentMaxWidth: CGFloat { isWide ? 520 : .infinity }

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    topLabel
                        .padding(.top, isWide ? 56 : 48)

                    heroSection
                        .padding(.top, 32)
                        .padding(.bottom, 36)

                    statsRow
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)

                    if !earnedWins.isEmpty {
                        earnedSection
                            .padding(.horizontal, 24)
                            .padding(.bottom, 32)
                    }

                    actionButtons
                        .padding(.horizontal, 24)
                        .padding(.bottom, 56)
                }
                .frame(maxWidth: contentMaxWidth)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            if reduceMotion {
                appeared = true
            } else {
                withAnimation(.easeOut(duration: 0.7)) {
                    appeared = true
                }
            }
            Task {
                try? await Task.sleep(for: .milliseconds(600))
                iconBounce += 1
            }
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

    private var backgroundGradient: some View {
        ZStack {
            EarnedColors.immersiveGradient

            RadialGradient(
                colors: [
                    EarnedColors.momentum.opacity(0.18),
                    Color.clear,
                ],
                center: .top,
                startRadius: 20,
                endRadius: 350
            )

            RadialGradient(
                colors: [
                    EarnedColors.accentGlow.opacity(0.08),
                    Color.clear,
                ],
                center: .center,
                startRadius: 0,
                endRadius: 200
            )

            LinearGradient(
                colors: [
                    Color.black.opacity(0.2),
                    Color.clear,
                    Color.clear,
                    Color.black.opacity(0.3),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var topLabel: some View {
        Text("TODAY")
            .font(.caption2.weight(.heavy))
            .tracking(2.5)
            .foregroundStyle(.white.opacity(0.35))
            .opacity(appeared ? 1 : 0)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.1), value: appeared)
    }

    private var heroSection: some View {
        VStack(spacing: 20) {
            ZStack {
                if earnedWins.isEmpty {
                    Circle()
                        .fill(.white.opacity(0.06))
                        .frame(width: 80, height: 80)

                    Image(systemName: "moon.fill")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.white.opacity(0.3))
                } else {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    EarnedColors.earned.opacity(0.6),
                                    EarnedColors.earned.opacity(0.2),
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 48
                            )
                        )
                        .frame(width: 80, height: 80)

                    Text("\(earnedWins.count)")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .symbolEffect(.bounce, value: iconBounce)
                }
            }
            .scaleEffect(appeared ? 1 : 0.6)
            .opacity(appeared ? 1 : 0)
            .animation(reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.65).delay(0.15), value: appeared)

            Text(headline)
                .font(.system(size: 32, weight: .heavy))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .opacity(appeared ? 1 : 0)
                .offset(y: reduceMotion ? 0 : (appeared ? 0 : 16))
                .animation(reduceMotion ? nil : .easeOut(duration: 0.5).delay(0.25), value: appeared)
        }
        .accessibilityElement(children: .combine)
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(
                value: viewModel.consistencyRatio,
                label: "This Week"
            )

            statDivider

            statItem(
                value: "\(earnedWins.count)",
                label: "Earned"
            )

            statDivider

            statItem(
                value: trendSymbol,
                label: "Momentum"
            )
        }
        .padding(.vertical, 16)
        .background(.white.opacity(0.07))
        .clipShape(.rect(cornerRadius: 14))
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 10))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.35), value: appeared)
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
        VStack(spacing: 5) {
            Text(value)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label.uppercased())
                .font(.system(size: 9, weight: .heavy))
                .tracking(0.8)
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(width: 0.5, height: 28)
    }

    private var earnedSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("WHAT YOU EARNED")
                .font(.caption2.weight(.heavy))
                .tracking(1.8)
                .foregroundStyle(.white.opacity(0.3))
                .padding(.leading, 4)
                .padding(.bottom, 14)
                .opacity(appeared ? 1 : 0)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.4), value: appeared)

            VStack(spacing: 0) {
                ForEach(Array(earnedWins.enumerated()), id: \.element.id) { index, win in
                    earnedRow(win: win, index: index)

                    if index < earnedWins.count - 1 {
                        Rectangle()
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 0.5)
                            .padding(.leading, 58)
                    }
                }
            }
            .background(.white.opacity(0.06))
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private func earnedRow(win: Win, index: Int) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(win.category.color.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: win.category.icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(win.category.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(win.text)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)

                Text(win.category.displayName)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(win.category.color.opacity(0.7))
            }

            Spacer()

            Image(systemName: "checkmark")
                .font(.caption.weight(.bold))
                .foregroundStyle(EarnedColors.earned)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 8))
        .animation(reduceMotion ? nil : .spring(response: 0.4).delay(0.45 + Double(index) * 0.06), value: appeared)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Earned: \(win.text)")
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
                    .background(.white)
                    .foregroundStyle(EarnedColors.deepNavy)
                    .clipShape(.rect(cornerRadius: 16))
                }
                .sensoryFeedback(.impact(flexibility: .soft), trigger: viewModel.showSayItOutLoud)
            } else {
                Button {
                    viewModel.dismissSummary()
                } label: {
                    Text("Continue")
                        .font(.body.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(.white)
                        .foregroundStyle(EarnedColors.deepNavy)
                        .clipShape(.rect(cornerRadius: 16))
                }
            }

            if !earnedWins.isEmpty {
                Button {
                    showShareSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.body.weight(.medium))
                        Text("Share")
                            .font(.body.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(.white.opacity(0.1))
                    .foregroundStyle(.white.opacity(0.85))
                    .clipShape(.rect(cornerRadius: 16))
                }
            }

            Button {
                viewModel.startOver()
            } label: {
                Text("Redo")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(.top, 4)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 12))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.6), value: appeared)
    }
}
