import SwiftUI

struct DayDetailView: View {
    let viewModel: EarnedViewModel
    let date: Date
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared: Bool = false
    @State private var showShareCard: Bool = false
    @State private var journalText: String = ""
    @State private var isEditingNote: Bool = false
    @State private var showExportSheet: Bool = false
    @State private var pdfURL: URL?
    @State private var showResultsCard: Bool = false
    @State private var resultsCardImage: UIImage?
    @State private var savedToPhotos: Bool = false
    @State private var isSavingImage: Bool = false
    @FocusState private var noteIsFocused: Bool

    private var dateKey: String { DailyEntry.dateKey(for: date) }
    private var entry: DailyEntry? { viewModel.entries[dateKey] }
    private var earnedWins: [Win] { viewModel.earnedWins(for: dateKey) }
    private var isComeback: Bool { entry?.isComeback == true }

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }

    private var headline: String {
        let count = earnedWins.count
        if count == 0 && isComeback { return "You came back." }
        if count == 0 { return "Rest day." }
        if isComeback { return "You came back." }
        if count == 1 { return "You showed up." }
        if count <= 3 { return "You earned it." }
        return "You owned it."
    }

    private var subline: String {
        let count = earnedWins.count
        if count == 0 && isComeback { return "Showing up is progress." }
        if count == 0 { return "Progress continues." }
        return "\(count) wins earned"
    }

    private var hasNote: Bool {
        !journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    if !earnedWins.isEmpty {
                        earnedSection
                    }
                    journalSection
                    exportButtons
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(dateLabel)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !earnedWins.isEmpty {
                        Button {
                            showShareCard = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .fontWeight(.semibold)
                                .foregroundStyle(EarnedColors.accent)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        saveNoteIfNeeded()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(EarnedColors.accent)
                }
            }
            .sheet(isPresented: $showShareCard) {
                ShareCardSheet(
                    wins: earnedWins,
                    affirmation: entry?.sayItOutLoudStatement ?? SayItOutLoudLibrary.statement(for: earnedWins),
                    earnedCount: earnedWins.count,
                    streak: viewModel.currentStreak,
                    trendLabel: viewModel.trendLabel
                )
            }
            .sheet(isPresented: $showExportSheet) {
                if let url = pdfURL {
                    ShareSheet(items: [url])
                }
            }
            .sheet(isPresented: $showResultsCard) {
                resultsCardSheet
            }
            .onAppear {
                journalText = entry?.journalNote ?? ""
                if reduceMotion { appeared = true }
                else { withAnimation(.easeOut(duration: 0.5)) { appeared = true } }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                if earnedWins.isEmpty && !isComeback {
                    Circle()
                        .fill(Color(.quaternarySystemFill))
                        .frame(width: 80, height: 80)

                    Image(systemName: "minus")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.tertiary)
                } else if isComeback && earnedWins.isEmpty {
                    Circle()
                        .fill(EarnedColors.momentum.opacity(0.2))
                        .frame(width: 80, height: 80)

                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(EarnedColors.momentum)
                } else {
                    Circle()
                        .fill(EarnedColors.earnedGradient)
                        .frame(width: 80, height: 80)

                    Text("\(earnedWins.count)")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
            .scaleEffect(appeared ? 1 : 0.8)
            .opacity(appeared ? 1 : 0)

            VStack(spacing: 6) {
                Text(headline)
                    .font(.title3.weight(.bold))

                Text(subline)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(EarnedColors.accent)
            }
            .opacity(appeared ? 1 : 0)
        }
        .padding(.vertical, 12)
    }

    private var earnedSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("EARNED")
                .font(.caption.weight(.heavy))
                .tracking(1.5)
                .foregroundStyle(EarnedColors.earned)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                ForEach(Array(earnedWins.enumerated()), id: \.element.id) { index, win in
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(win.category.color.opacity(0.15))
                                .frame(width: 38, height: 38)

                            Image(systemName: win.category.icon)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(win.category.color)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(win.text)
                                .font(.body.weight(.semibold))

                            Text(win.category.displayName)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(win.category.color)
                        }

                        Spacer()

                        Image(systemName: "checkmark.circle.fill")
                            .font(.body)
                            .foregroundStyle(EarnedColors.earned)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: reduceMotion ? 0 : (appeared ? 0 : 8))
                    .animation(reduceMotion ? nil : .spring(response: 0.4).delay(0.1 + Double(index) * 0.05), value: appeared)

                    if index < earnedWins.count - 1 {
                        Divider().padding(.leading, 68)
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private var journalSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("JOURNAL")
                    .font(.caption.weight(.heavy))
                    .tracking(1.5)
                    .foregroundStyle(EarnedColors.accent)

                Spacer()

                if hasNote && !isEditingNote {
                    Button {
                        isEditingNote = true
                        noteIsFocused = true
                    } label: {
                        Image(systemName: "pencil")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(EarnedColors.accent)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            if isEditingNote || !hasNote {
                VStack(spacing: 12) {
                    TextField("Add a personal note...", text: $journalText, axis: .vertical)
                        .font(.body)
                        .lineLimit(3...8)
                        .focused($noteIsFocused)
                        .padding(14)

                    if isEditingNote || hasNote {
                        HStack {
                            Spacer()
                            Button {
                                saveNoteIfNeeded()
                                isEditingNote = false
                                noteIsFocused = false
                            } label: {
                                Text("Save")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(EarnedColors.accent)
                                    .clipShape(Capsule())
                            }
                            .padding(.trailing, 14)
                            .padding(.bottom, 12)
                        }
                    }
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 16))
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    Text(journalText)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 16))
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: reduceMotion ? 0 : (appeared ? 0 : 8))
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.2), value: appeared)
    }

    private var exportButtons: some View {
        VStack(spacing: 10) {
            Button {
                exportPDF()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "doc.richtext")
                        .font(.body.weight(.semibold))

                    Text("Export as PDF")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(EarnedColors.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(EarnedColors.accent.opacity(0.1))
                .clipShape(.rect(cornerRadius: 14))
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: showExportSheet)

            Button {
                showResultsCard = true
                renderResultsCard()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body.weight(.semibold))

                    Text("Share Results Card")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(EarnedColors.earnedGradient)
                .clipShape(.rect(cornerRadius: 14))
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: showResultsCard)
        }
        .opacity(appeared ? 1 : 0)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4).delay(0.3), value: appeared)
    }

    private func saveNoteIfNeeded() {
        let trimmed = journalText.trimmingCharacters(in: .whitespacesAndNewlines)
        let current = entry?.journalNote ?? ""
        if trimmed != current {
            viewModel.saveJournalNote(for: dateKey, note: trimmed)
        }
    }

    private var resultsCardSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let image = resultsCardImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(.rect(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.3), radius: 16, y: 8)
                            .padding(.horizontal, 20)
                    } else {
                        ProgressView()
                            .frame(height: 300)
                    }

                    HStack(spacing: 12) {
                        Button {
                            saveResultsCardToPhotos()
                        } label: {
                            HStack(spacing: 6) {
                                if savedToPhotos {
                                    Image(systemName: "checkmark")
                                    Text("Saved")
                                } else if isSavingImage {
                                    ProgressView()
                                        .controlSize(.small)
                                } else {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("Save")
                                }
                            }
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(savedToPhotos ? EarnedColors.earned : .primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(.rect(cornerRadius: 14))
                        }
                        .sensoryFeedback(.success, trigger: savedToPhotos)

                        if let image = resultsCardImage {
                            ShareLink(
                                item: Image(uiImage: image),
                                preview: SharePreview("MVM Earned", image: Image(uiImage: image))
                            ) {
                                HStack(spacing: 6) {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share")
                                }
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(EarnedColors.earnedGradient)
                                .clipShape(.rect(cornerRadius: 14))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Results Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showResultsCard = false
                        savedToPhotos = false
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(EarnedColors.accent)
                }
            }
        }
    }

    @MainActor
    private func renderResultsCard() {
        let cardView = ResultsCardView(
            date: date,
            wins: earnedWins,
            journalNote: journalText.isEmpty ? nil : journalText,
            isComeback: isComeback,
            isRendering: true
        )

        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 3
        resultsCardImage = renderer.uiImage
    }

    private func saveResultsCardToPhotos() {
        guard let image = resultsCardImage else { return }
        isSavingImage = true
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isSavingImage = false
            savedToPhotos = true
        }
    }

    private func exportPDF() {
        saveNoteIfNeeded()
        let data = JournalPDFService.generatePDF(
            date: date,
            wins: earnedWins,
            journalNote: journalText.isEmpty ? nil : journalText,
            isComeback: isComeback
        )

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let fileName = "MVM-Earned-\(formatter.string(from: date)).pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try data.write(to: tempURL)
            pdfURL = tempURL
            showExportSheet = true
        } catch {
            // Silently fail
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
