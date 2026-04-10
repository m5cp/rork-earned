import SwiftUI

struct WeeklyReflectionView: View {
    @Bindable var viewModel: EarnedViewModel
    @FocusState private var isFocused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared: Bool = false

    var body: some View {
        ZStack {
            backgroundLayer.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [EarnedColors.momentum.opacity(0.4), EarnedColors.momentum.opacity(0.1)],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 32
                                    )
                                )
                                .frame(width: 64, height: 64)

                            Image(systemName: "text.bubble.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(EarnedColors.momentumBright)
                        }

                        Text("Weekly Reflection")
                            .font(.system(size: 24, weight: .black))
                            .foregroundStyle(.white)
                            .raisedHeadline()

                        Text("What was your biggest win this week?")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.65))
                    }

                    weekSummary
                        .padding(.horizontal, 4)

                    TextEditor(text: $viewModel.weeklyReflectionText)
                        .scrollContentBackground(.hidden)
                        .font(.body)
                        .foregroundStyle(.white)
                        .frame(height: 120)
                        .padding(14)
                        .background(.white.opacity(0.08))
                        .clipShape(.rect(cornerRadius: 14))
                        .focused($isFocused)
                        .overlay(alignment: .topLeading) {
                            if viewModel.weeklyReflectionText.isEmpty {
                                Text("Reflect on what went well...")
                                    .font(.body)
                                    .foregroundStyle(.white.opacity(0.3))
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 22)
                                    .allowsHitTesting(false)
                            }
                        }

                    VStack(spacing: 12) {
                        Button {
                            viewModel.saveWeeklyReflection()
                        } label: {
                            Text("Save Reflection")
                                .font(.headline.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(viewModel.weeklyReflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .white.opacity(0.2) : .white)
                                .foregroundStyle(viewModel.weeklyReflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .white.opacity(0.4) : EarnedColors.deepNavy)
                                .clipShape(.rect(cornerRadius: 16))
                        }
                        .disabled(viewModel.weeklyReflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                        Button {
                            viewModel.dismissWeeklyReflection()
                        } label: {
                            Text("Skip")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                }
                .padding(28)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.08, green: 0.08, blue: 0.2),
                                        Color(red: 0.04, green: 0.04, blue: 0.12),
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                RadialGradient(
                                    colors: [EarnedColors.momentum.opacity(0.08), Color.clear],
                                    center: .top,
                                    startRadius: 0,
                                    endRadius: 200
                                )
                            )

                        RoundedRectangle(cornerRadius: 28)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [EarnedColors.momentum.opacity(0.2), Color.white.opacity(0.06)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                )
                .padding(.horizontal, 20)
                .scaleEffect(appeared ? 1 : 0.95)
                .opacity(appeared ? 1 : 0)

                Spacer()
            }
        }
        .onAppear {
            if reduceMotion { appeared = true }
            else { withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { appeared = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isFocused = true }
        }
    }

    private var weekSummary: some View {
        HStack(spacing: 0) {
            miniStat(value: "\(viewModel.weeklyEarnedCount)", label: "Wins")
            miniStatDivider
            miniStat(value: "\(viewModel.daysActiveInLast(7))/7", label: "Days")
            miniStatDivider
            miniStat(value: "\(viewModel.currentStreak)", label: "Streak")
        }
        .padding(.vertical, 10)
        .background(.white.opacity(0.06))
        .clipShape(.rect(cornerRadius: 10))
    }

    private func miniStat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .monospacedDigit()
            Text(label.uppercased())
                .font(.system(size: 8, weight: .heavy))
                .tracking(0.5)
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }

    private var miniStatDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.12))
            .frame(width: 0.5, height: 22)
    }

    private var backgroundLayer: some View {
        ZStack {
            Color.black.opacity(0.7)

            RadialGradient(
                colors: [EarnedColors.momentum.opacity(0.08), Color.clear],
                center: .center,
                startRadius: 0,
                endRadius: 300
            )
        }
    }
}
