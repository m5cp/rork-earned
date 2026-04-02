import SwiftUI

struct ContentView: View {
    @State private var viewModel = EarnedViewModel()
    @State private var selectedTab: Int = 0
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Today", systemImage: "checkmark.circle.fill", value: 0) {
                todayFlow
            }

            Tab("Progress", systemImage: "chart.bar.fill", value: 1) {
                EarnedProgressView(viewModel: viewModel)
            }

            Tab("Settings", systemImage: "gearshape.fill", value: 2) {
                SettingsView(viewModel: viewModel)
            }
        }
        .tint(EarnedColors.accent)
        .preferredColorScheme(appTheme.colorScheme)
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
                SummaryView(viewModel: viewModel)
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
