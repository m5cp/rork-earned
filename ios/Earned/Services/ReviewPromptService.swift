import StoreKit
import SwiftUI

enum ReviewPromptService {
    private static let lastPromptDateKey = "lastReviewPromptDate"
    private static let totalPromptsKey = "totalReviewPrompts"

    static func requestReviewIfAppropriate(streak: Int, level: Int, milestonesUnlocked: Int) {
        guard shouldPrompt(streak: streak, level: level, milestonesUnlocked: milestonesUnlocked) else { return }

        UserDefaults.standard.set(Date.now.timeIntervalSince1970, forKey: lastPromptDateKey)
        let total = UserDefaults.standard.integer(forKey: totalPromptsKey)
        UserDefaults.standard.set(total + 1, forKey: totalPromptsKey)

        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    private static func shouldPrompt(streak: Int, level: Int, milestonesUnlocked: Int) -> Bool {
        let total = UserDefaults.standard.integer(forKey: totalPromptsKey)
        guard total < 3 else { return false }

        let lastTimestamp = UserDefaults.standard.double(forKey: lastPromptDateKey)
        if lastTimestamp > 0 {
            let lastDate = Date(timeIntervalSince1970: lastTimestamp)
            let daysSince = Calendar.current.dateComponents([.day], from: lastDate, to: .now).day ?? 0
            guard daysSince >= 30 else { return false }
        }

        let isPositiveMoment = streak == 7 || streak == 14 || streak == 30 || level == 3 || level == 5 || milestonesUnlocked == 5 || milestonesUnlocked == 10
        return isPositiveMoment
    }
}
