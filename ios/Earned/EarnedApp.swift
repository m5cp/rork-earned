import SwiftUI
import AppIntents
import RevenueCat
import GameKit

@main
struct EarnedApp: App {
    init() {
        #if DEBUG
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY)
        #else
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY)
        #endif
        EarnedShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    refreshScheduledNotifications()
                }
        }
    }

    private func refreshScheduledNotifications() {
        let entries: [String: DailyEntry]
        if let data = UserDefaults.standard.data(forKey: "earned_entries"),
           let decoded = try? JSONDecoder().decode([String: DailyEntry].self, from: data) {
            entries = decoded
        } else {
            entries = [:]
        }

        if UserDefaults.standard.bool(forKey: "weeklyMomentumEnabled") {
            let momentum = WeeklyMomentumService.generateMomentum(from: entries)
            WeeklyMomentumService.scheduleWeeklyNotification(for: momentum)
        }

        if UserDefaults.standard.bool(forKey: "nudgeEnabled") {
            let nudgeTime: Date
            if let saved = UserDefaults.standard.object(forKey: "nudgeTime") as? Date {
                nudgeTime = saved
            } else {
                var components = DateComponents()
                components.hour = 9
                components.minute = 0
                nudgeTime = Calendar.current.date(from: components) ?? .now
            }

            let frequency: DailyNudgeService.NudgeFrequency
            if let rawFreq = UserDefaults.standard.string(forKey: "nudgeFrequency"),
               let freq = DailyNudgeService.NudgeFrequency(rawValue: rawFreq) {
                frequency = freq
            } else {
                frequency = .daily
            }

            let todayKey = DailyEntry.dateKey()
            let hasCompleted = entries[todayKey].map { !$0.earnedWinIDs.isEmpty } ?? false

            DailyNudgeService.scheduleNudges(
                time: nudgeTime,
                frequency: frequency,
                hasCompletedToday: hasCompleted
            )
        }
    }
}
