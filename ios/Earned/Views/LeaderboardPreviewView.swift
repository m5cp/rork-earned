import SwiftUI
import GameKit

struct LeaderboardPreviewView: View {
    let gameCenter: GameCenterService
    @State private var topPlayers: [LeaderboardEntry] = []
    @State private var isLoading: Bool = false
    @State private var playerRank: Int?
    @State private var appeared: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "trophy.fill")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(EarnedColors.streak)

                Text("Leaderboard")
                    .font(.subheadline.weight(.bold))

                Spacer()

                if gameCenter.isAuthenticated {
                    Button {
                        gameCenter.showLeaderboard()
                    } label: {
                        HStack(spacing: 4) {
                            Text("See All")
                                .font(.caption.weight(.bold))
                            Image(systemName: "chevron.right")
                                .font(.caption2.weight(.bold))
                        }
                        .foregroundStyle(EarnedColors.accent)
                    }
                }
            }
            .padding(.horizontal, 4)

            if !gameCenter.isAuthenticated {
                notAuthenticatedCard
            } else if isLoading {
                loadingCard
            } else if topPlayers.isEmpty {
                emptyCard
            } else {
                leaderboardList
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 10))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.08), value: appeared)
        .onAppear {
            if reduceMotion { appeared = true }
            else { withAnimation(.easeOut(duration: 0.5)) { appeared = true } }
            if gameCenter.isAuthenticated { loadLeaderboard() }
        }
    }

    private var notAuthenticatedCard: some View {
        Button {
            gameCenter.authenticate()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(EarnedColors.streak.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(EarnedColors.streak)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Sign in to compete")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("See how you rank globally")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private var loadingCard: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .padding(.vertical, 24)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var emptyCard: some View {
        VStack(spacing: 8) {
            Text("No leaderboard data yet")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Text("Complete check-ins to appear on the board")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var leaderboardList: some View {
        VStack(spacing: 0) {
            ForEach(Array(topPlayers.prefix(5).enumerated()), id: \.element.id) { index, entry in
                HStack(spacing: 14) {
                    Text("#\(entry.rank)")
                        .font(.system(.caption, design: .rounded, weight: .heavy))
                        .foregroundStyle(rankColor(entry.rank))
                        .frame(width: 32)

                    if entry.rank <= 3 {
                        Image(systemName: rankIcon(entry.rank))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(rankColor(entry.rank))
                            .frame(width: 20)
                    } else {
                        Color.clear.frame(width: 20, height: 20)
                    }

                    Text(entry.displayName)
                        .font(.subheadline.weight(entry.isLocalPlayer ? .bold : .medium))
                        .foregroundStyle(entry.isLocalPlayer ? EarnedColors.accent : .primary)
                        .lineLimit(1)

                    Spacer()

                    Text("\(entry.score)")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                        .monospacedDigit()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(entry.isLocalPlayer ? EarnedColors.accent.opacity(0.08) : .clear)

                if index < min(topPlayers.count, 5) - 1 {
                    Divider().padding(.leading, 60)
                }
            }

            if let rank = playerRank, rank > 5 {
                Divider()
                HStack(spacing: 14) {
                    Text("···")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.tertiary)
                        .frame(width: 32)

                    Color.clear.frame(width: 20, height: 20)

                    Text("You")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(EarnedColors.accent)

                    Spacer()

                    Text("#\(rank)")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(EarnedColors.accent)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(EarnedColors.accent.opacity(0.08))
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: Color(.systemYellow)
        case 2: Color(.systemGray)
        case 3: Color(.systemOrange)
        default: .secondary
        }
    }

    private func rankIcon(_ rank: Int) -> String {
        switch rank {
        case 1: "medal.fill"
        case 2: "medal.fill"
        case 3: "medal.fill"
        default: ""
        }
    }

    private func loadLeaderboard() {
        isLoading = true
        Task {
            do {
                let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: ["earned.totalWins"])
                guard let board = leaderboards.first else {
                    isLoading = false
                    return
                }

                let (localEntry, entries, _) = try await board.loadEntries(
                    for: .global,
                    timeScope: .allTime,
                    range: NSRange(location: 1, length: 10)
                )

                var results: [LeaderboardEntry] = []
                for entry in entries {
                    results.append(LeaderboardEntry(
                        rank: entry.rank,
                        displayName: entry.player.displayName,
                        score: entry.score,
                        isLocalPlayer: entry.player == GKLocalPlayer.local
                    ))
                }

                topPlayers = results.sorted { $0.rank < $1.rank }
                playerRank = localEntry?.rank
                isLoading = false
            } catch {
                isLoading = false
            }
        }
    }
}

private struct LeaderboardEntry: Identifiable {
    let id: String = UUID().uuidString
    let rank: Int
    let displayName: String
    let score: Int
    let isLocalPlayer: Bool
}
