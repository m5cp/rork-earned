import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var currentPage: Int = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared: Bool = false

    private let pages: [(icon: String, iconColors: [Color], title: String, subtitle: String)] = [
        (
            "checkmark.circle.fill",
            [Color(red: 0.22, green: 0.48, blue: 1.0), Color(red: 0.5, green: 0.32, blue: 1.0)],
            "Own your wins.",
            "Every day, you'll see cards that reflect real progress — things you actually did. Swipe right to earn them."
        ),
        (
            "flame.fill",
            [Color(red: 1.0, green: 0.52, blue: 0.12), Color(red: 0.92, green: 0.24, blue: 0.34)],
            "Build momentum.",
            "Track your streaks, unlock milestones, and level up as you stay consistent. Small wins compound."
        ),
        (
            "quote.opening",
            [Color(red: 0.5, green: 0.32, blue: 1.0), Color(red: 0.22, green: 0.48, blue: 1.0)],
            "Say it out loud.",
            "After each check-in, declare what you earned. Speaking it makes it real. Share it if you want — or keep it for yourself."
        ),
    ]

    var body: some View {
        ZStack {
            backgroundLayer.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        pageContent(page: page, index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(reduceMotion ? nil : .smooth(duration: 0.4), value: currentPage)

                Spacer()

                pageIndicator
                    .padding(.bottom, 28)

                actionButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)

                skipButton
                    .padding(.bottom, 36)
            }
        }
        .onAppear {
            if reduceMotion { appeared = true }
            else { withAnimation(.easeOut(duration: 0.6)) { appeared = true } }
        }
    }

    private func pageContent(page: (icon: String, iconColors: [Color], title: String, subtitle: String), index: Int) -> some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [page.iconColors[0].opacity(0.3), page.iconColors[1].opacity(0.1)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: page.iconColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: page.iconColors[0].opacity(0.4), radius: 20, y: 8)

                Image(systemName: page.icon)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 14) {
                Text(page.title)
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(.white)
                    .raisedHeadline()

                Text(page.subtitle)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
        }
        .padding(.horizontal, 20)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(reduceMotion ? nil : .spring(response: 0.3), value: currentPage)
            }
        }
    }

    private var actionButton: some View {
        Button {
            if currentPage < pages.count - 1 {
                withAnimation(reduceMotion ? nil : .smooth(duration: 0.35)) {
                    currentPage += 1
                }
            } else {
                onComplete()
            }
        } label: {
            Text(currentPage < pages.count - 1 ? "Next" : "Let's Go")
                .font(.headline.weight(.bold))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(.white)
                .foregroundStyle(Color(red: 0.04, green: 0.05, blue: 0.14))
                .clipShape(.rect(cornerRadius: 16))
        }
        .sensoryFeedback(.impact(weight: .light), trigger: currentPage)
    }

    private var skipButton: some View {
        Group {
            if currentPage < pages.count - 1 {
                Button {
                    onComplete()
                } label: {
                    Text("Skip")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.5))
                }
            } else {
                Color.clear.frame(height: 20)
            }
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            EarnedColors.immersiveGradient

            RadialGradient(
                colors: [EarnedColors.accent.opacity(0.15), Color.clear],
                center: .top,
                startRadius: 30,
                endRadius: 400
            )
            .offset(y: -60)

            RadialGradient(
                colors: [EarnedColors.momentum.opacity(0.1), Color.clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 250
            )
        }
    }
}
