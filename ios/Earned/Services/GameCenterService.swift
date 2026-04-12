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

    private let leaderboardTotalWins = "earned.totalWins"
    private let leaderboardLongestStreak = "earned.longestStreak"
    private let leaderboardWeeklyWins = "earned.weeklyWins"
    private let leaderboardLevel = "earned.level"

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let vc = viewController {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.keyWindow?.rootViewController {
                    rootVC.present(vc, animated: true)
                }
            } else if GKLocalPlayer.local.isAuthenticated {
                Task { @MainActor in
                    self.isAuthenticated = true
                    self.playerDisplayName = GKLocalPlayer.local.displayName
                    self.isAnonymous = false
                }
            } else {
                Task { @MainActor in
                    self.isAuthenticated = false
                    self.isAnonymous = true
                    self.playerDisplayName = "Anonymous"
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
