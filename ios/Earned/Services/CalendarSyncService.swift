import EventKit
import SwiftUI

@MainActor
class CalendarSyncService {
    static let shared = CalendarSyncService()

    private let eventStore = EKEventStore()
    private let calendarNameKey = "Earned"
    private let syncEnabledKey = "calendarSyncEnabled"
    private let calendarIdentifierKey = "earnedCalendarIdentifier"

    var isSyncEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: syncEnabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: syncEnabledKey) }
    }

    var authorizationStatus: EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }

    func requestAccess() async -> Bool {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            return granted
        } catch {
            return false
        }
    }

    func syncSession(entry: DailyEntry, earnedWins: [Win], streak: Int, trend: String) {
        guard isSyncEnabled else { return }
        guard authorizationStatus == .fullAccess else { return }

        let calendar = getOrCreateEarnedCalendar()
        guard let calendar else { return }

        guard let eventDate = DailyEntry.date(from: entry.date) else { return }

        removeExistingEvent(for: eventDate, in: calendar)

        let event = EKEvent(eventStore: eventStore)
        event.calendar = calendar
        event.isAllDay = true

        let startOfDay = Calendar.current.startOfDay(for: eventDate)
        event.startDate = startOfDay
        event.endDate = startOfDay

        let earnedCount = entry.earnedCount
        event.title = "Earned: \(earnedCount) win\(earnedCount == 1 ? "" : "s")"

        var notes: [String] = []
        for win in earnedWins {
            notes.append("✓ \(win.text)")
        }
        if streak > 1 {
            notes.append("")
            notes.append("\(streak)-day streak")
        }
        if !trend.isEmpty {
            notes.append("Momentum: \(trend)")
        }
        event.notes = notes.joined(separator: "\n")

        do {
            try eventStore.save(event, span: .thisEvent)
        } catch {
            // Silent failure — calendar sync is a nice-to-have
        }
    }

    func removeSync(for dateKey: String) {
        guard let calendar = findEarnedCalendar() else { return }
        guard let date = DailyEntry.date(from: dateKey) else { return }
        removeExistingEvent(for: date, in: calendar)
    }

    private func getOrCreateEarnedCalendar() -> EKCalendar? {
        if let existing = findEarnedCalendar() {
            return existing
        }

        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        newCalendar.title = calendarNameKey

        if let iCloud = eventStore.sources.first(where: { $0.sourceType == .calDAV && $0.title.localizedCaseInsensitiveContains("icloud") }) {
            newCalendar.source = iCloud
        } else if let local = eventStore.sources.first(where: { $0.sourceType == .local }) {
            newCalendar.source = local
        } else if let defaultSource = eventStore.defaultCalendarForNewEvents?.source {
            newCalendar.source = defaultSource
        } else {
            return nil
        }

        newCalendar.cgColor = UIColor(red: 0.22, green: 0.48, blue: 1.0, alpha: 1.0).cgColor

        do {
            try eventStore.saveCalendar(newCalendar, commit: true)
            UserDefaults.standard.set(newCalendar.calendarIdentifier, forKey: calendarIdentifierKey)
            return newCalendar
        } catch {
            return nil
        }
    }

    private func findEarnedCalendar() -> EKCalendar? {
        if let savedID = UserDefaults.standard.string(forKey: calendarIdentifierKey),
           let calendar = eventStore.calendars(for: .event).first(where: { $0.calendarIdentifier == savedID }) {
            return calendar
        }
        return eventStore.calendars(for: .event).first(where: { $0.title == calendarNameKey })
    }

    private func removeExistingEvent(for date: Date, in calendar: EKCalendar) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else { return }

        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: [calendar])
        let existing = eventStore.events(matching: predicate)

        for event in existing where event.title?.hasPrefix("Earned:") == true {
            try? eventStore.remove(event, span: .thisEvent)
        }
    }
}
