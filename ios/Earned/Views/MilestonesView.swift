import SwiftUI

struct MilestonesView: View {
    let viewModel: EarnedViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                levelHeader
                
                if !viewModel.nextMilestones.isEmpty {
                    nextUpSection
                }

                if !viewModel.unlockedMilestones.isEmpty {
                    unlockedSection
                }

                lockedSection
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Milestones")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if reduceMotion { appeared = true }
            else { withAnimation(.easeOut(duration: 0.5)) { appeared = true } }
        }
    }

    private var levelHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [EarnedColors.momentum.opacity(0.4), EarnedColors.accent.opacity(0.15)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 44
                        )
                    )
                    .frame(width: 88, height: 88)

                Circle()
                    .strokeBorder(
                        AngularGradient(
                            colors: [EarnedColors.accent, EarnedColors.momentum, EarnedColors.earned, EarnedColors.accent],
                            center: .center
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 88, height: 88)

                Text("\(viewModel.currentLevel)")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(EarnedColors.accent)
            }
            .scaleEffect(appeared ? 1 : 0.7)
            .opacity(appeared ? 1 : 0)
            .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.65), value: appeared)

            VStack(spacing: 4) {
                Text(viewModel.levelTitle)
                    .font(.title2.weight(.heavy))

                Text("\(viewModel.totalWinsEarned) total wins earned")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if viewModel.currentLevel < 10 {
                VStack(spacing: 8) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(.tertiarySystemFill))
                                .frame(height: 8)

                            Capsule()
                                .fill(EarnedColors.primaryGradient)
                                .frame(width: max(8, geo.size.width * viewModel.levelProgress), height: 8)
                                .animation(reduceMotion ? nil : .spring(response: 0.6), value: viewModel.levelProgress)
                        }
                    }
                    .frame(height: 8)

                    Text("\(viewModel.winsToNextLevel) wins to Level \(viewModel.currentLevel + 1)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 20))
        .opacity(appeared ? 1 : 0)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.1), value: appeared)
    }

    private var nextUpSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "target")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(EarnedColors.streak)
                Text("Next Up")
                    .font(.subheadline.weight(.bold))
            }
            .padding(.leading, 4)

            VStack(spacing: 0) {
                ForEach(Array(viewModel.nextMilestones.prefix(3).enumerated()), id: \.element.id) { index, milestone in
                    nextMilestoneRow(milestone: milestone, index: index)

                    if index < min(2, viewModel.nextMilestones.count - 1) {
                        Divider().padding(.leading, 60)
                    }
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 10))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.2), value: appeared)
    }

    private func nextMilestoneRow(milestone: Milestone, index: Int) -> some View {
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
                    .frame(width: 40, height: 40)

                Image(systemName: milestone.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(milestone.color.opacity(0.5))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(milestone.title)
                    .font(.subheadline.weight(.semibold))

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.tertiarySystemFill))
                            .frame(height: 5)

                        Capsule()
                            .fill(milestone.color)
                            .frame(width: max(5, geo.size.width * progress), height: 5)
                    }
                }
                .frame(height: 5)

                Text("\(current)/\(milestone.requirement) — \(milestone.description)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var unlockedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "trophy.fill")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(EarnedColors.earned)
                Text("Unlocked")
                    .font(.subheadline.weight(.bold))
                Spacer()
                Text("\(viewModel.unlockedMilestones.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(.capsule)
            }
            .padding(.leading, 4)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                ForEach(Array(viewModel.unlockedMilestones.reversed().enumerated()), id: \.element.id) { index, milestone in
                    unlockedBadge(milestone: milestone, index: index)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 10))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.3), value: appeared)
    }

    private func unlockedBadge(milestone: Milestone, index: Int) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [milestone.color.opacity(0.3), milestone.color.opacity(0.1)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 24
                        )
                    )
                    .frame(width: 48, height: 48)

                Image(systemName: milestone.icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(milestone.color)
            }

            Text(milestone.title)
                .font(.caption2.weight(.bold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
        .opacity(appeared ? 1 : 0)
        .animation(reduceMotion ? nil : .spring(response: 0.4).delay(0.35 + Double(index) * 0.04), value: appeared)
    }

    private var lockedSection: some View {
        let locked = MilestoneLibrary.all.filter { milestone in
            !viewModel.unlockedMilestones.contains(where: { $0.id == milestone.id }) &&
            !viewModel.nextMilestones.prefix(3).contains(where: { $0.id == milestone.id })
        }

        return Group {
            if !locked.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.tertiary)
                        Text("Locked")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.leading, 4)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                        ForEach(locked) { milestone in
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color(.tertiarySystemFill))
                                        .frame(width: 48, height: 48)

                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.quaternary)
                                }

                                Text(milestone.title)
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.tertiary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 14))
                        }
                    }
                }
                .opacity(appeared ? 1 : 0)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.4), value: appeared)
            }
        }
    }
}
