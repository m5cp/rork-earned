import Foundation
import WidgetKit

enum SharedDataService {
    static let appGroupID = "group.app.rork.earned.shared"
    private static let todayWinKey = "widget_today_win"
    private static let streakKey = "widget_streak"
    private static let earnedCountKey = "widget_earned_count"
    private static let consistencyKey = "widget_consistency"
    private static let lastCheckInKey = "widget_last_checkin"
    private static let categoryKey = "widget_category"
    private static let trendKey = "widget_trend"

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static func writeWidgetData(
        todayWin: String?,
        streak: Int,
        earnedCount: Int,
        consistency: String,
        topCategory: String?,
        trend: String
    ) {
        guard let defaults = sharedDefaults else { return }
        defaults.set(todayWin, forKey: todayWinKey)
        defaults.set(streak, forKey: streakKey)
        defaults.set(earnedCount, forKey: earnedCountKey)
        defaults.set(consistency, forKey: consistencyKey)
        defaults.set(topCategory, forKey: categoryKey)
        defaults.set(trend, forKey: trendKey)
        defaults.set(Date().timeIntervalSince1970, forKey: lastCheckInKey)
        WidgetCenter.shared.reloadAllTimelines()
    }

    static func readWidgetData() -> WidgetData {
        guard let defaults = sharedDefaults else {
            return WidgetData.empty
        }
        return WidgetData(
            todayWin: defaults.string(forKey: todayWinKey),
            streak: defaults.integer(forKey: streakKey),
            earnedCount: defaults.integer(forKey: earnedCountKey),
            consistency: defaults.string(forKey: consistencyKey) ?? "Start today",
            topCategory: defaults.string(forKey: categoryKey),
            trend: defaults.string(forKey: trendKey) ?? "Holding steady"
        )
    }
}

nonisolated struct WidgetData: Sendable {
    let todayWin: String?
    let streak: Int
    let earnedCount: Int
    let consistency: String
    let topCategory: String?
    let trend: String

    static let empty = WidgetData(
        todayWin: nil,
        streak: 0,
        earnedCount: 0,
        consistency: "Start today",
        topCategory: nil,
        trend: "Holding steady"
    )
}
