import Foundation
import UserNotifications

nonisolated struct DailyNudgeService: Sendable {

    nonisolated enum NudgeFrequency: String, CaseIterable, Identifiable, Sendable, Codable {
        case daily
        case fewTimesWeek

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .daily: "Every day"
            case .fewTimesWeek: "A few times a week"
            }
        }
    }

    private static let nudgeMessages: [[String]] = [
        [
            "Take a minute for yourself.",
            "A small moment counts.",
            "A quiet check-in, if you want.",
            "One moment, just for you.",
        ],
        [
            "Keep your momentum going.",
            "You can build on today.",
            "Add something to today.",
            "There's still something in today.",
        ],
        [
            "A quick moment of progress.",
            "Something small can grow.",
            "Today has room for something.",
            "A single step still moves forward.",
        ],
    ]

    static func scheduleNudges(time: Date, frequency: NudgeFrequency, hasCompletedToday: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: nudgeIdentifiers)

        if hasCompletedToday {
            scheduleFutureNudges(time: time, frequency: frequency, startingTomorrow: true)
        } else {
            scheduleFutureNudges(time: time, frequency: frequency, startingTomorrow: false)
        }
    }

    private static func scheduleFutureNudges(time: Date, frequency: NudgeFrequency, startingTomorrow: Bool) {
        let center = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

        let daysToSchedule: [Int]
        switch frequency {
        case .daily:
            daysToSchedule = Array(1...7)
        case .fewTimesWeek:
            daysToSchedule = [2, 4, 6]
        }

        for weekday in daysToSchedule {
            let message = randomMessage(for: weekday)

            let content = UNMutableNotificationContent()
            content.title = "MVM Earned"
            content.body = message
            content.sound = .default

            var trigger: UNCalendarNotificationTrigger

            if frequency == .daily {
                var components = DateComponents()
                components.hour = timeComponents.hour
                components.minute = timeComponents.minute
                trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

                let request = UNNotificationRequest(
                    identifier: "dailyNudge_repeating",
                    content: content,
                    trigger: trigger
                )
                center.add(request)
                return
            } else {
                var components = DateComponents()
                components.weekday = weekday
                components.hour = timeComponents.hour
                components.minute = timeComponents.minute
                trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

                let request = UNNotificationRequest(
                    identifier: "dailyNudge_\(weekday)",
                    content: content,
                    trigger: trigger
                )
                center.add(request)
            }
        }
    }

    private static func randomMessage(for seed: Int) -> String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 0
        let combined = dayOfYear + seed
        let categoryIndex = combined % nudgeMessages.count
        let category = nudgeMessages[categoryIndex]
        let messageIndex = (combined / nudgeMessages.count) % category.count
        return category[messageIndex]
    }

    static func cancelAllNudges() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: nudgeIdentifiers)
    }

    private static var nudgeIdentifiers: [String] {
        var ids = ["dailyNudge_repeating"]
        for i in 1...7 {
            ids.append("dailyNudge_\(i)")
        }
        return ids
    }
}
