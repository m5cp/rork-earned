import SwiftUI

struct AIJournalView: View {
    let viewModel: EarnedViewModel
    let dateKey: String
    @State private var isGenerating: Bool = false
    @State private var generationError: String?
    @State private var showRegenerateConfirm: Bool = false
    @State private var draftText: String = ""
    @State private var isEditing: Bool = false
    @State private var justSaved: Bool = false
    @FocusState private var editorFocused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var entry: DailyEntry? { viewModel.entries[dateKey] }
    private var hasSavedJournal: Bool {
        entry?.aiJournalEntry?.isEmpty == false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerRow

            if isGenerating {
                generatingState
            } else if !draftText.isEmpty || hasSavedJournal {
                journalEditor
            } else if let error = generationError {
                errorState(error)
            } else {
                generatePrompt
            }
        }
        .onAppear {
            if draftText.isEmpty {
                if let saved = entry?.aiJournalEntry, !saved.isEmpty {
                    draftText = saved
                } else if !isGenerating {
                    generateJournal()
                }
            }
        }
    }

    private var headerRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(EarnedColors.momentum)

            Text("YOUR JOURNAL")
                .font(.caption2.weight(.heavy))
                .tracking(1.5)
                .foregroundStyle(EarnedColors.momentumBright)

            Spacer()

            if !draftText.isEmpty && !isGenerating {
                Button {
                    showRegenerateConfirm = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.trianglehead.2.clockwise")
                            .font(.caption.weight(.bold))
                        Text("Regenerate")
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(.white.opacity(0.5))
                }
                .confirmationDialog("Regenerate journal entry?", isPresented: $showRegenerateConfirm) {
                    Button("Regenerate") { generateJournal() }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This will replace the current text.")
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

                Text("Turning your reflections into words")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.06))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var journalEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextEditor(text: $draftText)
                .scrollContentBackground(.hidden)
                .font(.body.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))
                .lineSpacing(4)
                .frame(minHeight: 160)
                .padding(14)
                .background(.white.opacity(0.06))
                .clipShape(.rect(cornerRadius: 16))
                .focused($editorFocused)
                .onChange(of: draftText) { _, _ in
                    if justSaved { justSaved = false }
                }

            HStack(spacing: 10) {
                if editorFocused {
                    Button {
                        editorFocused = false
                    } label: {
                        Text("Done")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }

                if hasSavedJournal && draftText == entry?.aiJournalEntry {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(EarnedColors.earned)
                        Text(justSaved ? "Saved to journal" : "In your journal")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .transition(.opacity)
                }

                Spacer()

                Button {
                    saveJournal()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.heavy))
                        Text(hasSavedJournal ? "Update" : "Save to Journal")
                            .font(.subheadline.weight(.bold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(canSave ? AnyShapeStyle(Color.white) : AnyShapeStyle(Color.white.opacity(0.15)))
                    .foregroundStyle(canSave ? EarnedColors.deepNavy : Color.white.opacity(0.3))
                    .clipShape(.rect(cornerRadius: 12))
                }
                .disabled(!canSave)
            }

            if let error = generationError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.8))
            }
        }
    }

    private var canSave: Bool {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        return trimmed != (entry?.aiJournalEntry ?? "")
    }

    private func errorState(_ error: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(error)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))

            Button {
                generateJournal()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption.weight(.bold))
                    Text("Try again")
                        .font(.caption.weight(.bold))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.white.opacity(0.12))
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 10))
            }
        }
        .padding(16)
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
                    Text("Write my journal entry")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)

                    Text("A warm reflection from today's answers")
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

    private func saveJournal() {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        viewModel.saveAIJournalEntry(for: dateKey, entry: trimmed)
        editorFocused = false
        withAnimation(.smooth(duration: 0.3)) {
            justSaved = true
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
                draftText = journalText
                isGenerating = false
            } catch {
                generationError = error.localizedDescription
                isGenerating = false
            }
        }
    }
}
