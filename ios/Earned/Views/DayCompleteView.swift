import SwiftUI

struct DayCompleteView: View {
    let viewModel: EarnedViewModel
    var store: StoreViewModel? = nil
    @State private var appeared: Bool = false
    @State private var glowPulse: Bool = false
    @State private var journalText: String = ""
    @State private var showJournalField: Bool = false
    @State private var aiAffirmation: String?
    @State private var isGeneratingAffirmation: Bool = false
    @FocusState private var journalFocused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var earnedCount: Int { viewModel.todayEarnedCount }

    private var encouragement: String {
        if viewModel.isPersonalBest { return "New personal best!" }
        if viewModel.tiedPersonalBest { return "Matched your best!" }
        let streak = viewModel.currentStreak
        if streak >= 30 { return "Unstoppable." }
        if streak >= 14 { return "Momentum is real." }
        if streak >= 7 { return "One week strong." }
        if streak >= 3 { return "Building something." }
        if earnedCount >= 4 { return "Strong session." }
        return "You showed up."
    }

    private var quote: (text: String, author: String) {
        MotivationalQuoteLibrary.randomQuote()
    }

    var body: some View {
        ZStack {
            backgroundLayer.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 60)

                    heroSection
                        .padding(.bottom, 32)

                    if viewModel.isPersonalBest || viewModel.tiedPersonalBest {
                        personalBestBadge
                            .padding(.horizontal, 24)
                            .padding(.bottom, 20)
                    }

                    statsRow
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)

                    quoteCard
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)

                    if viewModel.currentLevel < 10 {
                        levelProgressCard
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                    }

                    DailyChallengeCardView(viewModel: viewModel)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 8))
                        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.28), value: appeared)

                    if aiAffirmation != nil || isGeneratingAffirmation {
                        affirmationCard
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                    }

                    aiJournalSection
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)

                    journalSection
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)

                    if let next = viewModel.nextMilestones.first {
                        nextMilestoneCard(next)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                    }

                    TomorrowPreviewView()
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 8))
                        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.38), value: appeared)

                    MemoryCardView(viewModel: viewModel)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 8))
                        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.4), value: appeared)

                    streakShieldSection
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)

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
            generateAffirmationIfNeeded()
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

                Image(systemName: viewModel.isPersonalBest ? "trophy.fill" : "checkmark")
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
                        .contentTransition(.numericText())
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: reduceMotion ? 0 : (appeared ? 0 : 12))
            .animation(reduceMotion ? nil : .easeOut(duration: 0.5).delay(0.15), value: appeared)
        }
    }

    private var personalBestBadge: some View {
        HStack(spacing: 10) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(EarnedColors.streak)

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.isPersonalBest ? "NEW PERSONAL BEST" : "TIED PERSONAL BEST")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.5)
                    .foregroundStyle(EarnedColors.streak)

                Text("\(earnedCount) wins in a single session")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(EarnedColors.streak.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(EarnedColors.streak.opacity(0.25), lineWidth: 1)
                )
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 8))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.2), value: appeared)
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

    private var quoteCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "quote.opening")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(EarnedColors.accentBright.opacity(0.6))

            Text(quote.text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.85))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            Text("— \(quote.author)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.45))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.06))
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 8))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.28), value: appeared)
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

    private var journalSection: some View {
        VStack(spacing: 12) {
            if !showJournalField {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        showJournalField = true
                    }
                    Task {
                        try? await Task.sleep(for: .milliseconds(300))
                        journalFocused = true
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "square.and.pencil")
                            .font(.body.weight(.semibold))
                        Text("Add a Journal Note")
                            .font(.subheadline.weight(.bold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(0.08))
                    .foregroundStyle(.white.opacity(0.8))
                    .clipShape(.rect(cornerRadius: 16))
                }
            } else {
                VStack(spacing: 10) {
                    TextEditor(text: $journalText)
                        .scrollContentBackground(.hidden)
                        .font(.body)
                        .foregroundStyle(.white)
                        .frame(height: 100)
                        .padding(12)
                        .background(.white.opacity(0.08))
                        .clipShape(.rect(cornerRadius: 14))
                        .focused($journalFocused)
                        .overlay(alignment: .topLeading) {
                            if journalText.isEmpty {
                                Text("How are you feeling? What stood out today?")
                                    .font(.body)
                                    .foregroundStyle(.white.opacity(0.25))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 20)
                                    .allowsHitTesting(false)
                            }
                        }

                    HStack(spacing: 10) {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showJournalField = false
                                journalText = ""
                            }
                        } label: {
                            Text("Cancel")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.5))
                        }

                        Spacer()

                        Button {
                            viewModel.saveJournalNote(for: viewModel.todayKey, note: journalText)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showJournalField = false
                            }
                        } label: {
                            Text("Save")
                                .font(.subheadline.weight(.bold))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .white.opacity(0.15) : .white)
                                .foregroundStyle(journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .white.opacity(0.3) : EarnedColors.deepNavy)
                                .clipShape(.rect(cornerRadius: 10))
                        }
                        .disabled(journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 8))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.32), value: appeared)
    }

    private var streakShieldSection: some View {
        let shieldService = StreakShieldService.shared
        let remaining = shieldService.shieldsRemaining(isPremium: false)

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(EarnedColors.accentBright)

                Text("STREAK SHIELD")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.5)
                    .foregroundStyle(EarnedColors.accentBright.opacity(0.8))
            }

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(EarnedColors.accent.opacity(0.12))
                        .frame(width: 40, height: 40)

                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(EarnedColors.accent.opacity(0.7))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("\(remaining) shield\(remaining == 1 ? "" : "s") available")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)

                    Text("Protects your streak if you miss a day")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()
            }
            .padding(14)
            .background(.white.opacity(0.06))
            .clipShape(.rect(cornerRadius: 14))
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 8))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.42), value: appeared)
    }

    private var affirmationCard: some View {
        Group {
            if let affirmation = aiAffirmation {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(EarnedColors.streak)

                        Text("TODAY'S AFFIRMATION")
                            .font(.caption2.weight(.heavy))
                            .tracking(1.5)
                            .foregroundStyle(EarnedColors.streak.opacity(0.8))
                    }

                    Text(affirmation)
                        .font(.body.weight(.semibold).italic())
                        .foregroundStyle(.white.opacity(0.9))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.06))
                .clipShape(.rect(cornerRadius: 16))
            } else if isGeneratingAffirmation {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(EarnedColors.streak)
                    Text("Crafting your affirmation...")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.04))
                .clipShape(.rect(cornerRadius: 14))
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 8))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.29), value: appeared)
    }

    private func generateAffirmationIfNeeded() {
        guard aiAffirmation == nil, !isGeneratingAffirmation else { return }
        guard !viewModel.todayEarnedWins.isEmpty else { return }
        isGeneratingAffirmation = true
        Task {
            do {
                let result = try await GroqService.shared.generatePersonalizedAffirmation(
                    recentWins: viewModel.todayEarnedWins,
                    mood: viewModel.todayEntry?.mood,
                    streak: viewModel.currentStreak
                )
                aiAffirmation = result
            } catch {
                // Silently fail — affirmation is optional
            }
            isGeneratingAffirmation = false
        }
    }

    private var aiJournalSection: some View {
        AIJournalView(viewModel: viewModel, store: store, dateKey: viewModel.todayKey)
            .opacity(appeared ? 1 : 0)
            .offset(y: reduceMotion ? 0 : (appeared ? 0 : 8))
            .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.3), value: appeared)
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
