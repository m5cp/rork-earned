import Foundation
import Observation

@Observable
@MainActor
final class AnalyticsService {
    static let shared = AnalyticsService()

    private let optInKey = "analyticsOptIn"
    private let installTokenKey = "analyticsInstallToken"
    private let eventLogKey = "analyticsEventLog"
    private let maxStoredEvents = 200

    var isOptedIn: Bool {
        didSet {
            UserDefaults.standard.set(isOptedIn, forKey: optInKey)
        }
    }

    private init() {
        self.isOptedIn = UserDefaults.standard.bool(forKey: optInKey)
    }

    var installToken: String {
        if let existing = UserDefaults.standard.string(forKey: installTokenKey) {
            return existing
        }
        let token = UUID().uuidString
        UserDefaults.standard.set(token, forKey: installTokenKey)
        return token
    }

    func track(_ event: String, properties: [String: String] = [:]) {
        guard isOptedIn else { return }
        var log = storedEvents()
        let entry = LoggedEvent(
            name: event,
            properties: properties,
            timestamp: Date()
        )
        log.append(entry)
        if log.count > maxStoredEvents {
            log = Array(log.suffix(maxStoredEvents))
        }
        if let data = try? JSONEncoder().encode(log) {
            UserDefaults.standard.set(data, forKey: eventLogKey)
        }
    }

    func recentEvents(limit: Int = 50) -> [LoggedEvent] {
        Array(storedEvents().suffix(limit).reversed())
    }

    func clearEvents() {
        UserDefaults.standard.removeObject(forKey: eventLogKey)
    }

    private func storedEvents() -> [LoggedEvent] {
        guard let data = UserDefaults.standard.data(forKey: eventLogKey),
              let decoded = try? JSONDecoder().decode([LoggedEvent].self, from: data) else {
            return []
        }
        return decoded
    }
}

nonisolated struct LoggedEvent: Codable, Identifiable, Sendable {
    let id: UUID
    let name: String
    let properties: [String: String]
    let timestamp: Date

    init(name: String, properties: [String: String], timestamp: Date) {
        self.id = UUID()
        self.name = name
        self.properties = properties
        self.timestamp = timestamp
    }
}

nonisolated enum AnalyticsEvent {
    static let appOpen = "app_open"
    static let onboardingCompleted = "onboarding_completed"
    static let firstCheckInCompleted = "first_check_in_completed"
    static let checkInCompleted = "check_in_completed"
    static let paywallShown = "paywall_shown"
    static let paywallDismissed = "paywall_dismissed"
    static let paywallPurchased = "paywall_purchased"
    static let paywallRestored = "paywall_restored"
    static let shareCardOpened = "share_card_opened"
    static let milestoneUnlocked = "milestone_unlocked"
}
