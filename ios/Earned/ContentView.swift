import SwiftUI
import GameKit

struct ContentView: View {
    @State private var viewModel = EarnedViewModel()
    @State private var storeViewModel = StoreViewModel()
    @State private var gameCenter = GameCenterService.shared
    @State private var selectedTab: Int = 0
    @State private var showSplash: Bool = true
    @State private var showMilestoneCelebration: Bool = false
    @State private var showPaywallAfterFirstCheckIn: Bool = false
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome: Bool = false
    @AppStorage("hasSeenFirstCheckInPaywall") private var hasSeenFirstCheckInPaywall: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            if !hasSeenWelcome && !hasCompletedOnboarding && showSplash == false {
                WelcomeView {
                    withAnimation(.smooth(duration: 0.5)) {
                        hasSeenWelcome = true
                    }
                }
                .transition(.opacity)
            } else if !hasCompletedOnboarding && showSplash == false {
                OnboardingView {
                    withAnimation(.smooth(duration: 0.5)) {
                        hasCompletedOnboarding = true
                    }
                }
                .transition(.opacity)
            } else {
                mainContent
                    .opacity(showSplash ? 0 : 1)
            }

            if showSplash {
                SplashView {
                    withAnimation(.smooth(duration: 0.5)) {
                        showSplash = false
                    }
                }
                .transition(.opacity)
            }

            if showMilestoneCelebration, let milestone = viewModel.newlyUnlockedMilestone {
                MilestoneCelebrationView(
                    milestone: milestone,
                    onDismiss: {
                        withAnimation(.smooth(duration: 0.3)) {
                            showMilestoneCelebration = false
                            viewModel.dismissMilestoneCelebration()
                        }
                        triggerReviewPromptIfNeeded()
                    },
                    onShare: {
                        withAnimation(.smooth(duration: 0.3)) {
                            showMilestoneCelebration = false
                            viewModel.dismissMilestoneCelebration()
                        }
                        triggerReviewPromptIfNeeded()
                    }
                )
                .transition(.opacity)
                .zIndex(100)
            }

            if viewModel.showWeeklyReflection {
                WeeklyReflectionView(viewModel: viewModel)
                    .transition(.opacity)
                    .zIndex(99)
            }
        }
        .preferredColorScheme(appTheme.colorScheme)
        .onChange(of: viewModel.newlyUnlockedMilestone?.id) { _, newValue in
            if newValue != nil {
                withAnimation(.smooth(duration: 0.3)) {
                    showMilestoneCelebration = true
                }
            }
        }
        .onChange(of: viewModel.summaryDismissed) { _, dismissed in
            if dismissed {
                if !hasSeenFirstCheckInPaywall && !storeViewModel.isPremium {
                    hasSeenFirstCheckInPaywall = true
                    Task {
                        try? await Task.sleep(for: .milliseconds(800))
                        showPaywallAfterFirstCheckIn = true
                    }
                }

                let showReflection = viewModel.isEndOfWeek
                let isFirstReflection = !UserDefaults.standard.bool(forKey: "hasSeenWeeklyReflectionTeaser")
                if showReflection && (storeViewModel.isPremium || isFirstReflection) {
                    if isFirstReflection && !storeViewModel.isPremium {
                        UserDefaults.standard.set(true, forKey: "hasSeenWeeklyReflectionTeaser")
                    }
                    Task {
                        try? await Task.sleep(for: .milliseconds(1200))
                        withAnimation(.smooth(duration: 0.3)) {
                            viewModel.showWeeklyReflection = true
                        }
                    }
                }

                gameCenter.submitScores(
                    totalWins: viewModel.totalWinsEarned,
                    longestStreak: viewModel.longestStreak,
                    weeklyWins: viewModel.weeklyEarnedCount,
                    level: viewModel.currentLevel
                )

                triggerReviewPromptIfNeeded()
            }
        }
        .sheet(isPresented: $showPaywallAfterFirstCheckIn) {
            SubscriptionView(store: storeViewModel)
        }
        .onReceive(NotificationCenter.default.publisher(for: .earnedDeepLink)) { notification in
            guard let url = notification.object as? URL else { return }
            if url.host == "today" || url.path.contains("today") {
                selectedTab = 0
                AnalyticsService.shared.track("widget_opened")
            }
        }
    }

    private var mainContent: some View {
        TabView(selection: $selectedTab) {
            Tab("Today", systemImage: "checkmark.circle.fill", value: 0) {
                todayFlow
            }

            Tab("Journal", systemImage: "book.fill", value: 1) {
                NavigationStack {
                    JournalVaultView(viewModel: viewModel)
                }
            }

            Tab("Progress", systemImage: "chart.bar.fill", value: 2) {
                EarnedProgressView(viewModel: viewModel, gameCenter: gameCenter)
            }

            Tab("Settings", systemImage: "gearshape.fill", value: 3) {
                SettingsView(viewModel: viewModel, store: storeViewModel, gameCenter: gameCenter)
            }
        }
        .tint(EarnedColors.accent)
        .onChange(of: selectedTab) { _, newValue in
            let name: String = switch newValue {
            case 0: "today"
            case 1: "journal"
            case 2: "progress"
            case 3: "settings"
            default: "unknown"
            }
            AnalyticsService.shared.track("tab_viewed", properties: ["tab": name])
        }
    }

    private var todayFlow: some View {
        Group {
            if viewModel.showComeback {
                ComebackView {
                    withAnimation(reduceMotion ? nil : .smooth(duration: 0.45)) {
                        viewModel.logComeback()
                    }
                }
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.95)))
            } else if viewModel.showSayItOutLoud {
                SayItOutLoudView(
                    statement: viewModel.sayItOutLoudStatement,
                    onComplete: {
                        withAnimation(reduceMotion ? nil : .smooth(duration: 0.35)) {
                            viewModel.completeSayItOutLoud()
                        }
                    },
                    onDismiss: {
                        withAnimation(reduceMotion ? nil : .smooth(duration: 0.35)) {
                            viewModel.dismissSayItOutLoud()
                        }
                    }
                )
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .trailing)))
            } else if viewModel.showMoodCheck && !viewModel.moodCheckComplete {
                MoodCheckView(
                    onMoodSelected: { mood in
                        viewModel.saveMood(for: viewModel.todayKey, mood: mood)
                        withAnimation(reduceMotion ? nil : .smooth(duration: 0.4)) {
                            viewModel.moodCheckComplete = true
                            viewModel.showMoodCheck = false
                            viewModel.showSummary = true
                        }
                    },
                    onSkip: {
                        withAnimation(reduceMotion ? nil : .smooth(duration: 0.4)) {
                            viewModel.moodCheckComplete = true
                            viewModel.showMoodCheck = false
                            viewModel.showSummary = true
                        }
                    }
                )
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.95)))
            } else if viewModel.showSummary {
                SummaryView(viewModel: viewModel, onNavigateToProgress: {
                    selectedTab = 2
                })
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .trailing)))
            } else if viewModel.checkInComplete && viewModel.summaryDismissed {
                DayCompleteView(viewModel: viewModel)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.98)))
            } else {
                TodayView(viewModel: viewModel)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .leading)))
            }
        }
        .animation(reduceMotion ? .none : .smooth(duration: 0.4), value: viewModel.showComeback)
        .animation(reduceMotion ? .none : .smooth(duration: 0.4), value: viewModel.showMoodCheck)
        .animation(reduceMotion ? .none : .smooth(duration: 0.4), value: viewModel.moodCheckComplete)
        .animation(reduceMotion ? .none : .smooth(duration: 0.4), value: viewModel.showSummary)
        .animation(reduceMotion ? .none : .smooth(duration: 0.4), value: viewModel.showSayItOutLoud)
        .animation(reduceMotion ? .none : .smooth(duration: 0.4), value: viewModel.summaryDismissed)
    }

    private func triggerReviewPromptIfNeeded() {
        ReviewPromptService.requestReviewIfAppropriate(
            streak: viewModel.currentStreak,
            level: viewModel.currentLevel,
            milestonesUnlocked: viewModel.unlockedMilestones.count
        )
    }
}
