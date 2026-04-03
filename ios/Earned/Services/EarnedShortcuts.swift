import AppIntents

struct StartCheckInIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Check-In"
    static var description = IntentDescription("Open MVM Earned and start your daily check-in.")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        return .result(dialog: "Opening your daily check-in.")
    }
}

struct ViewStreakIntent: AppIntent {
    static var title: LocalizedStringResource = "View My Streak"
    static var description = IntentDescription("See your current Earned streak.")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let defaults = UserDefaults(suiteName: "group.app.rork.earned.shared")
        let streak = defaults?.integer(forKey: "widget_streak") ?? 0
        let earned = defaults?.integer(forKey: "widget_earned_count") ?? 0

        if streak > 0 {
            return .result(dialog: "You're on a \(streak)-day streak with \(earned) wins earned today. Keep going!")
        } else {
            return .result(dialog: "No active streak yet. Open the app to start checking in!")
        }
    }
}

struct GetDailyWinIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Today's Win"
    static var description = IntentDescription("Hear one of today's earned wins.")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let defaults = UserDefaults(suiteName: "group.app.rork.earned.shared")
        if let win = defaults?.string(forKey: "widget_today_win") {
            return .result(dialog: "\(win)")
        } else {
            return .result(dialog: "You haven't checked in yet today. Open the app to earn your wins!")
        }
    }
}

struct EarnedShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartCheckInIntent(),
            phrases: [
                "Start my check-in on \(.applicationName)",
                "Open \(.applicationName)",
                "Check in on \(.applicationName)"
            ],
            shortTitle: "Start Check-In",
            systemImageName: "checkmark.circle.fill"
        )
        AppShortcut(
            intent: ViewStreakIntent(),
            phrases: [
                "How's my streak on \(.applicationName)",
                "What's my \(.applicationName) streak",
                "Show my streak on \(.applicationName)"
            ],
            shortTitle: "View Streak",
            systemImageName: "flame.fill"
        )
        AppShortcut(
            intent: GetDailyWinIntent(),
            phrases: [
                "Give me a win from \(.applicationName)",
                "What did I earn on \(.applicationName)",
                "Today's win on \(.applicationName)"
            ],
            shortTitle: "Today's Win",
            systemImageName: "star.fill"
        )
    }

    static var shortcutTileColor: ShortcutTileColor = .teal
}
