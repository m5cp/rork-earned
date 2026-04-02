import SwiftUI

struct WeeklyMomentumCardView: View {
    let viewModel: EarnedViewModel
    @State private var showDetail: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared: Bool = false

    private var momentum: WeeklyMomentum { viewModel.weeklyMomentum }

    var body: some View {
        Button {
            showDetail = true
        } label: {
            cardContent
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetail) {
            WeeklyMomentumDetailView(viewModel: viewModel)
        }
        .onAppear {
            if reduceMotion { appeared = true }
            else { withAnimation(.easeOut(duration: 0.6)) { appeared = true } }
        }
    }

    private var cardContent: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Text("THIS WEEK")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.8)
                    .foregroundStyle(.white.opacity(0.5))

                Text(viewModel.weeklyMomentumHeadline)
                    .font(.system(size: 26, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)

                if !momentum.isEmpty {
                    Text(viewModel.weeklyMomentumSubheadline)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.top, 28)
            .padding(.bottom, momentum.isEmpty ? 28 : 18)
            .padding(.horizontal, 20)

            if !momentum.isEmpty {
                statsRow
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
            }
        }
        .frame(maxWidth: .infinity)
        .background(cardBackground)
        .clipShape(.rect(cornerRadius: 22))
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 12))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.5), value: appeared)
    }

    private var cardBackground: some View {
        ZStack {
            EarnedColors.immersiveGradient

            RadialGradient(
                colors: [
                    EarnedColors.momentum.opacity(0.22),
                    Color.clear,
                ],
                center: .center,
                startRadius: 10,
                endRadius: 160
            )
            .offset(y: -10)

            RadialGradient(
                colors: [
                    EarnedColors.accentGlow.opacity(0.06),
                    Color.clear,
                ],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 140
            )

            LinearGradient(
                colors: [
                    Color.black.opacity(0.25),
                    Color.clear,
                    Color.clear,
                    Color.black.opacity(0.2),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statPill(value: "\(momentum.daysActive)", label: "DAYS")

            pillDivider

            statPill(value: "\(momentum.totalEarned)", label: "EARNED")

            if momentum.daysActive > 0 {
                pillDivider
                HStack(spacing: 4) {
                    Text("MOMENTUM")
                        .font(.system(size: 9, weight: .heavy))
                        .tracking(0.5)
                    Image(systemName: trendArrow)
                        .font(.system(size: 9, weight: .bold))
                }
                .foregroundStyle(.white.opacity(0.55))
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.07))
        .clipShape(.rect(cornerRadius: 12))
    }

    private func statPill(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            Text(label)
                .font(.system(size: 9, weight: .heavy))
                .tracking(0.8)
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }

    private var pillDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(width: 0.5, height: 24)
    }

    private var trendArrow: String {
        switch viewModel.trend {
        case .up: "arrow.up"
        case .down: "arrow.right"
        case .steady: "arrow.right"
        }
    }
}
