import SwiftUI

struct JournalVaultView: View {
    let viewModel: EarnedViewModel
    @State private var searchText: String = ""
    @State private var selectedFilter: VaultFilter = .all
    @State private var selectedDate: IdentifiableDate?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared: Bool = false

    private var filteredEntries: [(key: String, entry: DailyEntry)] {
        var result = viewModel.allEntriesSorted

        switch selectedFilter {
        case .all: break
        case .journaled:
            result = result.filter { $0.entry.aiJournalEntry != nil || $0.entry.journalNote != nil }
        case .moods:
            result = result.filter { $0.entry.mood != nil }
        }

        if !searchText.isEmpty {
            result = result.filter { pair in
                let wins = viewModel.earnedWins(for: pair.key)
                let winMatch = wins.contains { $0.text.localizedStandardContains(searchText) }
                let journalMatch = pair.entry.aiJournalEntry?.localizedStandardContains(searchText) == true
                let noteMatch = pair.entry.journalNote?.localizedStandardContains(searchText) == true
                return winMatch || journalMatch || noteMatch
            }
        }

        return result
    }

    var body: some View {
        ScrollView {
            if filteredEntries.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 16) {
                    if viewModel.averageMood != nil {
                        moodSummaryCard
                    }

                    ForEach(Array(filteredEntries.enumerated()), id: \.element.key) { index, pair in
                        Button {
                            if let date = DailyEntry.date(from: pair.key) {
                                selectedDate = IdentifiableDate(date: date)
                            }
                        } label: {
                            vaultCard(dateKey: pair.key, entry: pair.entry)
                        }
                        .buttonStyle(.plain)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 8))
                        .animation(reduceMotion ? nil : .spring(response: 0.4).delay(min(0.3, Double(index) * 0.04)), value: appeared)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .scrollIndicators(.hidden)
        .searchable(text: $searchText, prompt: "Search wins, journal entries...")
        .navigationTitle("Journal Vault")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(VaultFilter.allCases) { filter in
                        Button {
                            selectedFilter = filter
                        } label: {
                            Label(filter.label, systemImage: filter.icon)
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .fontWeight(.semibold)
                        .foregroundStyle(selectedFilter == .all ? EarnedColors.accent : EarnedColors.momentum)
                }
            }
        }
        .sheet(item: $selectedDate) { item in
            DayDetailView(viewModel: viewModel, date: item.date)
        }
        .onAppear {
            if reduceMotion { appeared = true }
            else { withAnimation(.easeOut(duration: 0.5)) { appeared = true } }
        }
    }

    private func vaultCard(dateKey: String, entry: DailyEntry) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let date = DailyEntry.date(from: dateKey) {
                    Text(date, format: .dateTime.weekday(.wide).month(.abbreviated).day())
                        .font(.caption.weight(.bold))
                        .foregroundStyle(EarnedColors.accent)
                }

                Spacer()

                HStack(spacing: 8) {
                    if let mood = entry.mood {
                        Text(mood.emoji)
                            .font(.caption)
                    }

                    Text("\(entry.earnedCount) wins")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }
            }

            if let aiJournal = entry.aiJournalEntry {
                Text(aiJournal)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(3)
                    .lineSpacing(2)
            } else if let note = entry.journalNote {
                Text(note)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(3)
                    .lineSpacing(2)
            }

            let wins = viewModel.earnedWins(for: dateKey)
            if !wins.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 6) {
                        ForEach(wins.prefix(4)) { win in
                            HStack(spacing: 4) {
                                Image(systemName: win.category.icon)
                                    .font(.system(size: 9, weight: .bold))
                                Text(win.category.displayName)
                                    .font(.system(size: 10, weight: .semibold))
                            }
                            .foregroundStyle(win.category.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(win.category.color.opacity(0.1))
                            .clipShape(Capsule())
                        }
                        if wins.count > 4 {
                            Text("+\(wins.count - 4)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(.tertiarySystemFill))
                                .clipShape(Capsule())
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .contentMargins(.horizontal, 0)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 18))
    }

    private var moodSummaryCard: some View {
        HStack(spacing: 14) {
            let recentMoods = viewModel.moodHistory.prefix(7)

            VStack(alignment: .leading, spacing: 6) {
                Text("MOOD TREND")
                    .font(.caption2.weight(.heavy))
                    .tracking(1)
                    .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    ForEach(Array(recentMoods.reversed().enumerated()), id: \.element.date) { _, item in
                        Text(item.mood.emoji)
                            .font(.system(size: 18))
                    }
                }
            }

            Spacer()

            if let avg = viewModel.averageMood {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%.1f", avg))
                        .font(.system(.title3, design: .rounded, weight: .bold))
                    Text("avg / 5")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 18))
        .opacity(appeared ? 1 : 0)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4), value: appeared)
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 80)

            ZStack {
                Circle()
                    .fill(EarnedColors.momentum.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "book.closed.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(EarnedColors.momentum.opacity(0.5))
            }

            VStack(spacing: 8) {
                Text("Your Vault Is Empty")
                    .font(.title3.weight(.bold))

                Text("Complete check-ins to build\nyour personal journal.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
    }
}

nonisolated enum VaultFilter: String, CaseIterable, Identifiable, Sendable {
    case all
    case journaled
    case moods

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: "All Entries"
        case .journaled: "With Journal"
        case .moods: "With Mood"
        }
    }

    var icon: String {
        switch self {
        case .all: "list.bullet"
        case .journaled: "doc.text"
        case .moods: "face.smiling"
        }
    }
}
