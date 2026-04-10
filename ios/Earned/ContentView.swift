import SwiftUI

struct ContentView: View {
    @State private var viewModel = EarnedViewModel()
    @State private var storeViewModel = StoreViewModel()
    @State private var selectedTab: Int = 0
    @State private var showSplash: Bool = true
    @State private var showMilestoneCelebration: Bool = false
    @State private var showPaywallAfterFirstCheckIn: Bool = false
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("hasSeenFirstCheckInPaywall") private var hasSeenFirstCheckInPaywall: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            if !hasCompletedOnboarding && showSplash == false {
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
                    },
                    onShare: {
                        withAnimation(.smooth(duration: 0.3)) {
                            showMilestoneCelebration = false
                            viewModel.dismissMilestoneCelebration()
                        }
                    }
                )
                .transition(.opacity)
                .zIndex(100)
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
            if dismissed && !hasSeenFirstCheckInPaywall && !storeViewModel.isPremium {
                hasSeenFirstCheckInPaywall = true
                Task {
                    try? await Task.sleep(for: .milliseconds(800))
                    showPaywallAfterFirstCheckIn = true
                }
            }
        }
        .sheet(isPresented: $showPaywallAfterFirstCheckIn) {
            SubscriptionView(store: storeViewModel)
        }
    }

    private var mainContent: some View {
        TabView(selection: $selectedTab) {
            Tab("Today", systemImage: "checkmark.circle.fill", value: 0) {
                todayFlow
            }

            Tab("Progress", systemImage: "chart.bar.fill", value: 1) {
                EarnedProgressView(viewModel: viewModel)
            }

            Tab("Settings", systemImage: "gearshape.fill", value: 2) {
                SettingsView(viewModel: viewModel, store: storeViewModel)
            }
        }
        .tint(EarnedColors.accent)
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
            } else if viewModel.showSummary {
                SummaryView(viewModel: viewModel, onNavigateToProgress: {
                    selectedTab = 1
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
        .animation(reduceMotion ? .none : .smooth(duration: 0.4), value: viewModel.showSummary)
        .animation(reduceMotion ? .none : .smooth(duration: 0.4), value: viewModel.showSayItOutLoud)
        .animation(reduceMotion ? .none : .smooth(duration: 0.4), value: viewModel.summaryDismissed)
    }
}
