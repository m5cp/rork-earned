import SwiftUI

@Observable
@MainActor
class CoachChatViewModel {
    var messages: [CoachMessage] = []
    var inputText: String = ""
    var isLoading: Bool = false
    var error: String?

    private var earnedViewModel: EarnedViewModel?

    func setup(with viewModel: EarnedViewModel) {
        earnedViewModel = viewModel
        if messages.isEmpty {
            addWelcomeMessage()
        }
    }

    private func addWelcomeMessage() {
        guard let vm = earnedViewModel else { return }
        let streak = vm.currentStreak
        let totalWins = vm.totalWinsEarned
        let level = vm.currentLevel

        var greeting: String
        if streak >= 7 {
            greeting = "You're on a \(streak)-day streak — that's serious commitment. What's on your mind today?"
        } else if totalWins > 20 {
            greeting = "Level \(level) with \(totalWins) total wins. You've been putting in work. How can I help you today?"
        } else if streak > 0 {
            greeting = "\(streak)-day streak going. Every day you show up matters. What do you want to talk about?"
        } else {
            greeting = "Hey — glad you're here. I'm your personal coach. Tell me what's going on or ask me anything about your progress."
        }

        messages.append(CoachMessage(role: .assistant, content: greeting))
    }

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        messages.append(CoachMessage(role: .user, content: text))
        inputText = ""
        isLoading = true
        error = nil

        Task {
            do {
                let context = buildContext()
                var chatMessages: [(role: String, content: String)] = [
                    (role: "system", content: context)
                ]

                for msg in messages {
                    chatMessages.append((role: msg.role == .user ? "user" : "assistant", content: msg.content))
                }

                let response = try await GroqService.shared.chat(messages: chatMessages)
                messages.append(CoachMessage(role: .assistant, content: response))
                isLoading = false
            } catch {
                self.error = error.localizedDescription
                isLoading = false
            }
        }
    }

    private func buildContext() -> String {
        guard let vm = earnedViewModel else { return "" }

        let recentWins = vm.todayEarnedWins.map(\.text).joined(separator: ", ")
        let mood = vm.todayEntry?.mood?.label ?? "not tracked"
        let topCat = vm.topCategory?.displayName ?? "none yet"

        return """
        You are a supportive, direct personal growth coach inside the "Earned" app. \
        The user tracks daily wins by swiping cards. Be warm but not cheesy. Be encouraging but honest. \
        Keep responses concise — 2-3 sentences max unless they ask for more detail. \
        Reference their actual data when relevant. Never use emojis or hashtags. \
        If they share struggles, validate first, then offer a practical perspective.

        User data:
        - Current streak: \(vm.currentStreak) days
        - Total wins: \(vm.totalWinsEarned)
        - Level: \(vm.currentLevel) (\(vm.levelTitle))
        - Today's mood: \(mood)
        - Today's wins: \(recentWins.isEmpty ? "none yet" : recentWins)
        - Top category: \(topCat)
        - Days checked in: \(vm.totalDaysCheckedIn)
        - Longest streak: \(vm.longestStreak)
        """
    }
}

nonisolated struct CoachMessage: Identifiable, Sendable {
    let id: String = UUID().uuidString
    let role: CoachRole
    let content: String
    let timestamp: Date = .now
}

nonisolated enum CoachRole: Sendable {
    case user
    case assistant
}
