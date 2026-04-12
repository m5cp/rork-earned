import GameKit
import SwiftUI

@Observable
@MainActor
class GameCenterService {
    static let shared = GameCenterService()

    var isAuthenticated: Bool = false
    var playerDisplayName: String = "Anonymous"
    var isAnonymous: Bool = true
    var showGameCenter: Bool = false
    var isAuthenticating: Bool = false
    var authError: String? = nil

    private let leaderboardTotalWins = "earned.totalWins"
    private let leaderboardLongestStreak = "earned.longestStreak"
    private let leaderboardWeeklyWins = "earned.weeklyWins"
    private let leaderboardLevel = "earned.level"

    func authenticate() {
        isAuthenticating = true
        authError = nil
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isAuthenticating = false
                if let vc = viewController {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        var presenter = windowScene.keyWindow?.rootViewController
                        while let presented = presenter?.presentedViewController {
                            presenter = presented
                        }
                        presenter?.present(vc, animated: true)
                    }
                } else if GKLocalPlayer.local.isAuthenticated {
                    self.isAuthenticated = true
                    self.playerDisplayName = GKLocalPlayer.local.displayName
                    self.isAnonymous = false
                    self.authError = nil
                } else {
                    self.isAuthenticated = false
                    self.isAnonymous = true
                    self.playerDisplayName = "Anonymous"
                    if let error {
                        self.authError = "Sign in via Settings > Game Center on your device."
                    }
                }
            }
        }
    }

    func submitScores(totalWins: Int, longestStreak: Int, weeklyWins: Int, level: Int) {
        guard isAuthenticated else { return }
        Task {
            do {
                try await GKLeaderboard.submitScore(
                    totalWins,
                    context: 0,
                    player: GKLocalPlayer.local,
                    leaderboardIDs: [leaderboardTotalWins]
                )
                try await GKLeaderboard.submitScore(
                    longestStreak,
                    context: 0,
                    player: GKLocalPlayer.local,
                    leaderboardIDs: [leaderboardLongestStreak]
                )
                try await GKLeaderboard.submitScore(
                    weeklyWins,
                    context: 0,
                    player: GKLocalPlayer.local,
                    leaderboardIDs: [leaderboardWeeklyWins]
                )
                try await GKLeaderboard.submitScore(
                    level,
                    context: 0,
                    player: GKLocalPlayer.local,
                    leaderboardIDs: [leaderboardLevel]
                )
            } catch {
                print("Score submission failed: \(error.localizedDescription)")
            }
        }
    }

    func showLeaderboard() {
        guard isAuthenticated else { return }
        showGameCenter = true
    }
}

struct GameCenterDashboardView: UIViewControllerRepresentable {
    let viewState: GKGameCenterViewControllerState

    func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let gc = GKGameCenterViewController(state: viewState)
        gc.gameCenterDelegate = context.coordinator
        return gc
    }

    func updateUIViewController(_ uiViewController: GKGameCenterViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator: NSObject, GKGameCenterControllerDelegate {
        nonisolated func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            Task { @MainActor in
                gameCenterViewController.dismiss(animated: true)
            }
        }
    }
}
