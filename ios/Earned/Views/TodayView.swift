import SwiftUI

struct TodayView: View {
    let viewModel: EarnedViewModel

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dragOffset: CGSize = .zero
    @State private var appeared: Bool = false
    @State private var cardTransition: Bool = false
    @State private var arrowPulse: Bool = false
    @State private var glowPulse: Bool = false
    @State private var showSwipeHint: Bool = false
    @State private var earnHapticTrigger: Int = 0
    @State private var skipHapticTrigger: Int = 0
    @AppStorage("hasSeenSwipeHint") private var hasSeenSwipeHint: Bool = false

    private var isWide: Bool { horizontalSizeClass == .regular }
    private var cardMaxWidth: CGFloat { isWide ? 480 : .infinity }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        if hour < 12 { return "YOUR MORNING" }
        if hour < 17 { return "YOUR AFTERNOON" }
        return "YOUR EVENING"
    }

    private var powerPhrase: String {
        let dayHash = abs(DailyEntry.dateKey().hashValue)
        let phrases = [
            "Own this.",
            "Build on this.",
            "Earn it.",
            "Make it count.",
            "Your move.",
            "Start now.",
            "Claim today."
        ]
        return phrases[dayHash % phrases.count]
    }

    var body: some View {
        ZStack {
            backgroundLayer.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.top, 12)

                progressIndicator
                    .padding(.top, 20)
                    .padding(.horizontal, isWide ? 40 : 32)

                Spacer()

                cardStack
                    .frame(maxWidth: cardMaxWidth)
                    .padding(.horizontal, isWide ? 40 : 20)

                Spacer()

                swipeHints
                    .frame(maxWidth: cardMaxWidth)
                    .padding(.horizontal, isWide ? 40 : 24)
                    .padding(.bottom, 28)
            }
        }
        .onAppear {
            if reduceMotion {
                appeared = true
                glowPulse = true
            } else {
                withAnimation(.easeOut(duration: 0.6)) { appeared = true }
                glowPulse = true
            }
            arrowPulse = true
            viewModel.startLiveActivity()
            if !hasSeenSwipeHint && !reduceMotion {
                Task {
                    try? await Task.sleep(for: .milliseconds(800))
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                        showSwipeHint = true
                        dragOffset = CGSize(width: 60, height: 0)
                    }
                    try? await Task.sleep(for: .milliseconds(600))
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        dragOffset = .zero
                        showSwipeHint = false
                    }
                    hasSeenSwipeHint = true
                }
            }
        }
        .sensoryFeedback(.impact(weight: .heavy, intensity: 0.8), trigger: earnHapticTrigger)
        .sensoryFeedback(.impact(weight: .light, intensity: 0.4), trigger: skipHapticTrigger)
    }

    private var backgroundLayer: some View {
        ZStack {
            EarnedColors.immersiveGradient

            RadialGradient(
                colors: [
                    EarnedColors.accent.opacity(0.2),
                    Color.clear
                ],
                center: .top,
                startRadius: 30,
                endRadius: 400
            )
            .offset(y: -60)

            RadialGradient(
                colors: [
                    EarnedColors.momentum.opacity(glowPulse ? 0.12 : 0.06),
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 300
            )
            .animation(reduceMotion ? nil : .easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: glowPulse)

            RadialGradient(
                colors: [
                    EarnedColors.accent.opacity(0.06),
                    Color.clear
                ],
                center: .bottomLeading,
                startRadius: 0,
                endRadius: 250
            )

            LinearGradient(
                colors: [
                    Color.black.opacity(0.15),
                    Color.clear,
                    Color.clear,
                    Color.black.opacity(0.25)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(greeting)
                .font(.caption2.weight(.heavy))
                .tracking(3)
                .foregroundStyle(EarnedColors.accentBright)
                .raisedText()

            Text(powerPhrase)
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(.white)
                .raisedHeadline()
                .opacity(appeared ? 1 : 0)
                .offset(y: reduceMotion ? 0 : (appeared ? 0 : 10))
                .animation(reduceMotion ? nil : .easeOut(duration: 0.5).delay(0.15), value: appeared)
        }
        .opacity(appeared ? 1 : 0)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4), value: appeared)
    }

    private var progressIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<viewModel.todayWins.count, id: \.self) { index in
                Capsule()
                    .fill(
                        index < viewModel.currentCardIndex
                        ? AnyShapeStyle(EarnedColors.primaryGradient)
                        : index == viewModel.currentCardIndex
                            ? AnyShapeStyle(Color.white.opacity(0.7))
                            : AnyShapeStyle(Color.white.opacity(0.25))
                    )
                    .frame(height: 4)
                    .animation(reduceMotion ? nil : .snappy(duration: 0.3), value: viewModel.currentCardIndex)
            }
        }
        .frame(maxWidth: cardMaxWidth)
        .opacity(appeared ? 1 : 0)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.2), value: appeared)
    }

    private var cardStack: some View {
        ZStack {
            if viewModel.currentCardIndex + 2 < viewModel.todayWins.count {
                SwipeCardView(
                    win: viewModel.todayWins[viewModel.currentCardIndex + 2],
                    dragOffset: .zero,
                    isWide: isWide,
                    style: .immersive
                )
                .scaleEffect(0.88)
                .opacity(0.15)
                .offset(y: 12)
                .allowsHitTesting(false)
            }

            if viewModel.currentCardIndex + 1 < viewModel.todayWins.count {
                SwipeCardView(
                    win: viewModel.todayWins[viewModel.currentCardIndex + 1],
                    dragOffset: .zero,
                    isWide: isWide,
                    style: .immersive
                )
                .scaleEffect(0.93)
                .opacity(0.25)
                .offset(y: 6)
                .allowsHitTesting(false)
            }

            if let win = viewModel.currentWin {
                SwipeCardView(win: win, dragOffset: dragOffset, isWide: isWide, style: .immersive)
                    .id(win.id)
                    .offset(x: dragOffset.width, y: dragOffset.height * 0.15)
                    .rotationEffect(.degrees(reduceMotion ? 0 : dragOffset.width / 25))
                    .scaleEffect(appeared && !cardTransition ? 1 : 0.92)
                    .opacity(appeared && !cardTransition ? 1 : 0)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                guard !showSwipeHint else { return }
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                guard !showSwipeHint else { return }
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
            Button {
                guard !showSwipeHint else { return }
                swipeCard(direction: .left)
            } label: {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 52, height: 52)

                        Image(systemName: "arrowshape.left.fill")
                            .font(.system(size: 22, weight: .heavy))
                            .offset(x: arrowPulse ? -3 : 0)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: arrowPulse)
                    }
                    Text("SKIP")
                        .font(.caption2.weight(.black))
                        .tracking(2)
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white.opacity(0.8))
            .opacity(dragOffset.width < -20 ? 0.2 : 1)

            Spacer()

            VStack(spacing: 4) {
                Text("\(viewModel.currentCardIndex + 1)/\(viewModel.todayWins.count)")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(.white.opacity(0.7))
                    .monospacedDigit()
            }

            Spacer()

            Button {
                guard !showSwipeHint else { return }
                swipeCard(direction: .right)
            } label: {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(EarnedColors.earned.opacity(0.15))
                            .frame(width: 52, height: 52)

                        Image(systemName: "arrowshape.right.fill")
                            .font(.system(size: 22, weight: .heavy))
                            .offset(x: arrowPulse ? 3 : 0)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: arrowPulse)
                    }
                    Text("LOG IT")
                        .font(.caption2.weight(.black))
                        .tracking(2)
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(EarnedColors.earned)
            .opacity(dragOffset.width > 20 ? 0.2 : 1)
        }
        .opacity(appeared ? 1 : 0)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.35), value: appeared)
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
                earnHapticTrigger += 1
            } else {
                viewModel.skipWin(win)
                skipHapticTrigger += 1
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
