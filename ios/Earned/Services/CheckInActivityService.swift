import ActivityKit
import Foundation

enum CheckInActivityService {
    private static var currentActivity: Activity<CheckInActivityAttributes>?

    static func startSession(totalCards: Int, firstWinText: String, firstCategory: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        endSession()

        let attributes = CheckInActivityAttributes(sessionDate: DailyEntry.dateKey())
        let state = CheckInActivityAttributes.ContentState(
            earnedCount: 0,
            totalCards: totalCards,
            currentWinText: firstWinText,
            currentCategory: firstCategory
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
        } catch {
            // silently fail
        }
    }

    static func updateProgress(earnedCount: Int, totalCards: Int, currentWinText: String, currentCategory: String) {
        guard let activity = currentActivity else { return }

        let state = CheckInActivityAttributes.ContentState(
            earnedCount: earnedCount,
            totalCards: totalCards,
            currentWinText: currentWinText,
            currentCategory: currentCategory
        )

        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    static func endSession() {
        guard let activity = currentActivity else { return }

        let finalState = CheckInActivityAttributes.ContentState(
            earnedCount: 0,
            totalCards: 0,
            currentWinText: "",
            currentCategory: ""
        )

        Task {
            await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .immediate)
        }
        currentActivity = nil
    }
}
