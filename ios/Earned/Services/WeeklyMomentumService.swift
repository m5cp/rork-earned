import Foundation
import UserNotifications

nonisolated struct WeeklyMomentumService: Sendable {

    static func generateMomentum(from entries: [String: DailyEntry]) -> WeeklyMomentum {
        let calendar = Calendar.current
        let today = Date.now
        let weekStart = calendar.date(byAdding: .day, value: -6, to: today) ?? today

        var daysActive = 0
        var totalEarned = 0
        var comebackCount = 0
        var sayItOutLoudCount = 0

        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let key = DailyEntry.dateKey(for: date)
            guard let entry = entries[key] else { continue }

            if !entry.earnedWinIDs.isEmpty {
                daysActive += 1
            }
            let filtered = entry.earnedWinIDs.filter { $0 != Win.comebackID && $0 != Win.sayItOutLoudID }
            totalEarned += filtered.count

            if entry.isComeback {
                comebackCount += 1
            }
            if entry.sayItOutLoudCompleted {
                sayItOutLoudCount += 1
            }
        }

        return WeeklyMomentum(
            daysActive: daysActive,
            totalEarned: totalEarned,
            comebackCount: comebackCount,
            sayItOutLoudCount: sayItOutLoudCount,
            hadComeback: comebackCount > 0,
            weekStartDate: weekStart,
            weekEndDate: today
        )
    }

    static func headline(for momentum: WeeklyMomentum) -> String {
        if momentum.isEmpty { return "A new week ahead." }

        if momentum.daysActive >= 7 {
            return "You showed up every day."
        }
        if momentum.hadComeback && momentum.daysActive >= 3 {
            return "You came back and kept going."
        }
        if momentum.hadComeback {
            return "You came back. That counts."
        }
        if momentum.daysActive >= 5 {
            return "Your consistency is building."
        }
        if momentum.daysActive >= 3 {
            return "You kept showing up."
        }
        if momentum.totalEarned >= 10 {
            return "You created real momentum."
        }
        return "You showed up for yourself."
    }

    static func subheadline(for momentum: WeeklyMomentum) -> String {
        if momentum.isEmpty { return "Built from what you do." }

        if momentum.daysActive >= 7 {
            return "\(momentum.totalEarned) wins earned across 7 days"
        }
        if momentum.hadComeback {
            return "Coming back is part of the process."
        }
        if momentum.daysActive >= 5 {
            return "\(momentum.daysActive) of 7 days · \(momentum.totalEarned) wins earned"
        }
        if momentum.daysActive >= 3 {
            return "\(momentum.daysActive) days this week · Progress continues"
        }
        if momentum.daysActive == 1 {
            return "1 day this week · You were here"
        }
        return "\(momentum.daysActive) days this week · Small wins add up"
    }

    static func notificationMessage(for momentum: WeeklyMomentum) -> String? {
        if momentum.isEmpty { return nil }

        let messages: [(Bool, [String])] = [
            (momentum.daysActive >= 7, [
                "You showed up every day this week.",
                "Full week. That's real momentum."
            ]),
            (momentum.hadComeback && momentum.daysActive >= 3, [
                "You came back and kept going this week.",
                "You returned and built from there."
            ]),
            (momentum.hadComeback, [
                "You came back this week. That counts.",
                "You showed up again. Progress continues."
            ]),
            (momentum.daysActive >= 5, [
                "Your consistency is building.",
                "You kept showing up this week."
            ]),
            (momentum.daysActive >= 3, [
                "You stayed engaged this week.",
                "Small wins added up this week."
            ]),
            (momentum.sayItOutLoudCount >= 2, [
                "You reinforced your progress this week.",
                "Your effort showed up this week."
            ]),
            (momentum.daysActive >= 1, [
                "You showed up for yourself this week.",
                "You gave this week something to grow from."
            ])
        ]

        for (condition, pool) in messages {
            if condition {
                let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 0
                return pool[dayOfYear % pool.count]
            }
        }

        return nil
    }

    static func scheduleWeeklyNotification(for momentum: WeeklyMomentum) {
        guard let message = notificationMessage(for: momentum) else { return }

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["weeklyMomentum"])

        let content = UNMutableNotificationContent()
        content.title = "Your Week"
        content.body = message
        content.sound = .default

        var components = DateComponents()
        components.weekday = 1
        components.hour = 10
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "weeklyMomentum", content: content, trigger: trigger)

        center.add(request)
    }

    static func cancelWeeklyNotification() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["weeklyMomentum"])
    }
}
