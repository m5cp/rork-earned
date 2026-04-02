import SwiftUI

struct TodayView: View {
    let viewModel: EarnedViewModel

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dragOffset: CGSize = .zero
    @State private var appeared: Bool = false
    @State private var cardTransition: Bool = false

    private var isWide: Bool { horizontalSizeClass == .regular }
    private var cardMaxWidth: CGFloat { isWide ? 480 : .infinity }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: .now)
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.top, 8)

                progressBar
                    .padding(.top, 16)
                    .padding(.horizontal, isWide ? 40 : 24)

                Spacer()

                cardStack
                    .frame(maxWidth: cardMaxWidth)
                    .padding(.horizontal, isWide ? 40 : 24)

                Spacer()

                swipeHints
                    .frame(maxWidth: cardMaxWidth)
                    .padding(.horizontal, isWide ? 40 : 24)
                    .padding(.bottom, 24)
            }
        }
        .onAppear {
            if reduceMotion { appeared = true }
            else { withAnimation(.easeOut(duration: 0.5)) { appeared = true } }
        }
        .sensoryFeedback(.selection, trigger: viewModel.currentCardIndex)
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text(dateString.uppercased())
                .font(.caption2.weight(.heavy))
                .tracking(1.5)
                .foregroundStyle(.tertiary)

            Text("\(viewModel.currentCardIndex + 1) of \(viewModel.todayWins.count)")
                .font(.caption.weight(.bold))
                .foregroundStyle(EarnedColors.accent)
                .monospacedDigit()
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : -8)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let totalCards = max(viewModel.todayWins.count, 1)
            let filledWidth = totalWidth * CGFloat(viewModel.currentCardIndex) / CGFloat(totalCards)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.tertiarySystemFill))
                    .frame(height: 3)

                Capsule()
                    .fill(EarnedColors.accent)
                    .frame(width: max(0, filledWidth), height: 3)
                    .animation(reduceMotion ? nil : .snappy(duration: 0.3), value: viewModel.currentCardIndex)
            }
        }
        .frame(height: 3)
        .frame(maxWidth: cardMaxWidth)
    }

    private var cardStack: some View {
        ZStack {
            if viewModel.currentCardIndex + 1 < viewModel.todayWins.count {
                let nextWin = viewModel.todayWins[viewModel.currentCardIndex + 1]
                SwipeCardView(win: nextWin, dragOffset: .zero, isWide: isWide)
                    .scaleEffect(0.95)
                    .opacity(0.35)
                    .allowsHitTesting(false)
            }

            if let win = viewModel.currentWin {
                SwipeCardView(win: win, dragOffset: dragOffset, isWide: isWide)
                    .id(win.id)
                    .offset(x: dragOffset.width, y: dragOffset.height * 0.15)
                    .rotationEffect(.degrees(reduceMotion ? 0 : dragOffset.width / 25))
                    .scaleEffect(appeared && !cardTransition ? 1 : 0.92)
                    .opacity(appeared && !cardTransition ? 1 : 0)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                handleSwipe(value)
                            }
                    )
                    .animation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.8), value: dragOffset)
                    .accessibilityLabel("\(win.category.displayName): \(win.text)")
                    .accessibilityHint("Swipe right to earn, swipe left to skip")
                    .accessibilityAddTraits(.isButton)
            }
        }
    }

    private var swipeHints: some View {
        HStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.left")
                    .font(.subheadline.weight(.black))
                Text("SKIP")
                    .font(.caption.weight(.black))
                    .tracking(1.5)
            }
            .foregroundStyle(Color(.tertiaryLabel))
            .opacity(dragOffset.width < -20 ? 0.4 : 1)

            Spacer()

            HStack(spacing: 8) {
                Text("LOG IT")
                    .font(.caption.weight(.black))
                    .tracking(1.5)
                Image(systemName: "arrow.right")
                    .font(.subheadline.weight(.black))
            }
            .foregroundStyle(EarnedColors.earned)
            .opacity(dragOffset.width > 20 ? 0.4 : 1)
        }
        .opacity(appeared ? 1 : 0)
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    private func handleSwipe(_ value: DragGesture.Value) {
        let threshold: CGFloat = 80
        let velocity = value.velocity.width

        if value.translation.width > threshold || velocity > 500 {
            swipeCard(direction: .right)
        } else if value.translation.width < -threshold || velocity < -500 {
            swipeCard(direction: .left)
        } else {
            dragOffset = .zero
        }
    }

    private func swipeCard(direction: SwipeDirection) {
        let offscreenX: CGFloat = direction == .right ? 500 : -500

        withAnimation(reduceMotion ? .none : .snappy(duration: 0.25)) {
            dragOffset = CGSize(width: offscreenX, height: dragOffset.height)
        }

        Task {
            try? await Task.sleep(for: .milliseconds(reduceMotion ? 50 : 200))
            guard let win = viewModel.currentWin else { return }

            if direction == .right {
                viewModel.earnWin(win)
            } else {
                viewModel.skipWin(win)
            }

            cardTransition = true
            dragOffset = .zero

            if reduceMotion {
                cardTransition = false
            } else {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    cardTransition = false
                }
            }
        }
    }
}

nonisolated enum SwipeDirection: Sendable {
    case left, right
}
