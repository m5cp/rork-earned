import SwiftUI

struct DayCompleteView: View {
    let viewModel: EarnedViewModel
    @State private var appeared: Bool = false
    @State private var glowPulse: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var earnedCount: Int { viewModel.todayEarnedCount }

    private var encouragement: String {
        let streak = viewModel.currentStreak
        if streak >= 30 { return "Unstoppable." }
        if streak >= 14 { return "Momentum is real." }
        if streak >= 7 { return "One week strong." }
        if streak >= 3 { return "Building something." }
        if earnedCount >= 4 { return "Strong session." }
        return "You showed up."
    }

    var body: some View {
        ZStack {
            backgroundLayer.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 60)

                    heroSection
                        .padding(.bottom, 32)

                    statsRow
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)

                    if viewModel.currentLevel < 10 {
                        levelProgressCard
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                    }

                    if let next = viewModel.nextMilestones.first {
                        nextMilestoneCard(next)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 32)
                    }

                    actionButtons
                        .padding(.horizontal, 24)
                        .padding(.bottom, 48)
                }
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            if reduceMotion {
                appeared = true
                glowPulse = true
            } else {
                withAnimation(.easeOut(duration: 0.6)) { appeared = true }
                glowPulse = true
            }
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            EarnedColors.immersiveGradient

            RadialGradient(
                colors: [EarnedColors.earned.opacity(glowPulse ? 0.15 : 0.08), Color.clear],
                center: .top,
                startRadius: 20,
                endRadius: 350
            )
            .animation(reduceMotion ? nil : .easeInOut(duration: 3).repeatForever(autoreverses: true), value: glowPulse)

            RadialGradient(
                colors: [EarnedColors.accent.opacity(0.06), Color.clear],
                center: .bottomLeading,
                startRadius: 0,
                endRadius: 250
            )

            LinearGradient(
                colors: [Color.black.opacity(0.15), Color.clear, Color.clear, Color.black.opacity(0.25)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var heroSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [EarnedColors.earned.opacity(0.5), EarnedColors.earned.opacity(0.15)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 48
                        )
                    )
                    .frame(width: 88, height: 88)

                Image(systemName: "checkmark")
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(.white)
            }
            .scaleEffect(appeared ? 1 : 0.5)
            .opacity(appeared ? 1 : 0)
            .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.65), value: appeared)

            VStack(spacing: 10) {
                Text(encouragement)
                    .font(.system(size: 30, weight: .black))
                    .foregroundStyle(.white)
                    .raisedHeadline()

                if earnedCount > 0 {
                    Text("\(earnedCount) wins earned today")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(EarnedColors.earnedBright)
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: reduceMotion ? 0 : (appeared ? 0 : 12))
            .animation(reduceMotion ? nil : .easeOut(duration: 0.5).delay(0.15), value: appeared)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(value: "\(viewModel.currentStreak)", label: "Streak", icon: "flame.fill")
            statDivider
            statItem(value: "Lv \(viewModel.currentLevel)", label: viewModel.levelTitle, icon: "star.fill")
            statDivider
            statItem(value: "\(viewModel.totalWinsEarned)", label: "Total Wins", icon: "checkmark.circle.fill")
        }
        .padding(.vertical, 14)
        .background(.white.opacity(0.08))
        .clipShape(.rect(cornerRadius: 14))
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 10))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.25), value: appeared)
    }

    private func statItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .monospacedDigit()

            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 8, weight: .bold))
                Text(label.uppercased())
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(0.5)
            }
            .foregroundStyle(.white.opacity(0.6))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.15))
            .frame(width: 0.5, height: 28)
    }

    private var levelProgressCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("LEVEL \(viewModel.currentLevel)")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.5)
                    .foregroundStyle(EarnedColors.accentBright)

                Spacer()

                Text("\(viewModel.winsToNextLevel) to Lv \(viewModel.currentLevel + 1)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.5))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.12))
                        .frame(height: 8)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [EarnedColors.accent, EarnedColors.momentum],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, geo.size.width * viewModel.levelProgress), height: 8)
                        .animation(reduceMotion ? nil : .spring(response: 0.8).delay(0.4), value: appeared)
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .background(.white.opacity(0.06))
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 8))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.3), value: appeared)
    }

    private func nextMilestoneCard(_ milestone: Milestone) -> some View {
        let current: Int = switch milestone.type {
        case .streak: viewModel.longestStreak
        case .totalWins: viewModel.totalWinsEarned
        case .totalDays: viewModel.totalDaysCheckedIn
        case .comeback: viewModel.totalComebacks
        case .category: 0
        }
        let progress = min(1.0, Double(current) / Double(milestone.requirement))

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(milestone.color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: milestone.icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(milestone.color.opacity(0.6))
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(milestone.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)

                    Spacer()

                    Text("\(current)/\(milestone.requirement)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.4))
                        .monospacedDigit()
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.1))
                            .frame(height: 5)

                        Capsule()
                            .fill(milestone.color.opacity(0.6))
                            .frame(width: max(5, geo.size.width * progress), height: 5)
                    }
                }
                .frame(height: 5)

                Text(milestone.description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(16)
        .background(.white.opacity(0.06))
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 8))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.35), value: appeared)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                withAnimation(reduceMotion ? nil : .smooth(duration: 0.35)) {
                    viewModel.summaryDismissed = false
                    viewModel.showSummary = true
                }
            } label: {
                Text("View Summary")
                    .font(.body.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(.white)
                    .foregroundStyle(EarnedColors.deepNavy)
                    .clipShape(.rect(cornerRadius: 16))
            }

            Button {
                viewModel.startOver()
            } label: {
                Text("Redo")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.top, 4)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 10))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.4), value: appeared)
    }
}
