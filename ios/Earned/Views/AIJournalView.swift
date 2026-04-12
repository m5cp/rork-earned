import SwiftUI

struct AIJournalView: View {
    let viewModel: EarnedViewModel
    let dateKey: String
    @State private var isGenerating: Bool = false
    @State private var generationError: String?
    @State private var showRegenerateConfirm: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var entry: DailyEntry? { viewModel.entries[dateKey] }
    private var hasJournal: Bool { entry?.aiJournalEntry != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerRow

            if isGenerating {
                generatingState
            } else if let journalText = entry?.aiJournalEntry {
                journalContent(journalText)
            } else {
                generatePrompt
            }

            if let error = generationError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.8))
                    .padding(.horizontal, 4)
            }
        }
    }

    private var headerRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(EarnedColors.momentum)

            Text("AI JOURNAL")
                .font(.caption2.weight(.heavy))
                .tracking(1.5)
                .foregroundStyle(EarnedColors.momentumBright)

            Spacer()

            if hasJournal {
                Button {
                    showRegenerateConfirm = true
                } label: {
                    Image(systemName: "arrow.trianglehead.2.clockwise")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .confirmationDialog("Regenerate journal entry?", isPresented: $showRegenerateConfirm) {
                    Button("Regenerate") { generateJournal() }
                    Button("Cancel", role: .cancel) {}
                }
            }
        }
    }

    private var generatingState: some View {
        HStack(spacing: 14) {
            ProgressView()
                .tint(EarnedColors.momentum)

            VStack(alignment: .leading, spacing: 4) {
                Text("Writing your journal...")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.8))

                Text("AI is crafting a personal entry from your wins")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.06))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func journalContent(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(text)
                .font(.body.weight(.medium))
                .foregroundStyle(.white.opacity(0.85))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            if let generatedAt = entry?.aiJournalGeneratedAt {
                Text(generatedAt, style: .time)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.06))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var generatePrompt: some View {
        Button {
            generateJournal()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(EarnedColors.momentum.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(EarnedColors.momentum)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Generate AI Journal Entry")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)

                    Text("Turn today's wins into a personal reflection")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(14)
            .background(.white.opacity(0.08))
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private func generateJournal() {
        guard let entry = entry else { return }
        isGenerating = true
        generationError = nil

        let wins = viewModel.earnedWins(for: dateKey)
        let allWins = WinLibrary.all
        let skippedWins = entry.skippedWinIDs.compactMap { id in
            allWins.first { $0.id == id }
        }

        Task {
            do {
                let journalText = try await GroqService.shared.generateJournalEntry(
                    wins: wins,
                    skippedWins: skippedWins,
                    mood: entry.mood,
                    streak: viewModel.currentStreak,
                    isComeback: entry.isComeback,
                    userNote: entry.journalNote
                )
                viewModel.saveAIJournalEntry(for: dateKey, entry: journalText)
                isGenerating = false
            } catch {
                generationError = error.localizedDescription
                isGenerating = false
            }
        }
    }
}
