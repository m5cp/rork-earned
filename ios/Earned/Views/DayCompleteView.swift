import SwiftUI

struct DayCompleteView: View {
    let viewModel: EarnedViewModel
    @State private var appeared: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var earnedCount: Int { viewModel.todayEarnedCount }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(EarnedColors.earned.opacity(0.15))
                        .frame(width: 88, height: 88)

                    Image(systemName: "checkmark")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(EarnedColors.earned)
                }
                .scaleEffect(appeared ? 1 : 0.7)
                .opacity(appeared ? 1 : 0)

                VStack(spacing: 8) {
                    Text("You're done for today.")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundStyle(.primary)

                    if earnedCount > 0 {
                        Text("\(earnedCount) earned today")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(EarnedColors.accent)
                    }
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: reduceMotion ? 0 : (appeared ? 0 : 10))

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        withAnimation(reduceMotion ? nil : .smooth(duration: 0.35)) {
                            viewModel.summaryDismissed = false
                            viewModel.showSummary = true
                        }
                    } label: {
                        Text("View Summary")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(EarnedColors.accent)
                    }

                    Button {
                        viewModel.startOver()
                    } label: {
                        Text("Redo")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .opacity(appeared ? 1 : 0)
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            if reduceMotion { appeared = true }
            else { withAnimation(.easeOut(duration: 0.5)) { appeared = true } }
        }
    }
}
