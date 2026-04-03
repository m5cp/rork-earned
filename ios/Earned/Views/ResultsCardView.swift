import SwiftUI

struct ResultsCardView: View {
    let date: Date
    let wins: [Win]
    let journalNote: String?
    let isComeback: Bool
    let isRendering: Bool

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }

    private var headline: String {
        let count = wins.count
        if count == 0 && isComeback { return "You came back." }
        if count == 0 { return "Rest day." }
        if isComeback { return "You came back." }
        if count == 1 { return "You showed up." }
        if count <= 3 { return "You earned it." }
        return "You owned it."
    }

    var body: some View {
        VStack(spacing: 0) {
            headerArea
            if !wins.isEmpty {
                winsArea
            }
            if let note = journalNote, !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                journalArea(note)
            }
            Spacer(minLength: 12)
            footerArea
        }
        .padding(24)
        .frame(width: 390, height: calculatedHeight)
        .background(cardBackground)
        .clipShape(.rect(cornerRadius: 24))
    }

    private var cardBackground: some View {
        ZStack {
            Color(red: 0.06, green: 0.07, blue: 0.14)

            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0, 0], [0.5, 0], [1, 0],
                    [0, 0.5], [0.5, 0.5], [1, 0.5],
                    [0, 1], [0.5, 1], [1, 1]
                ],
                colors: [
                    Color(red: 0.08, green: 0.06, blue: 0.22),
                    Color(red: 0.04, green: 0.05, blue: 0.14),
                    Color(red: 0.06, green: 0.08, blue: 0.18),
                    Color(red: 0.04, green: 0.05, blue: 0.14),
                    Color(red: 0.1, green: 0.08, blue: 0.2),
                    Color(red: 0.06, green: 0.06, blue: 0.16),
                    Color(red: 0.06, green: 0.08, blue: 0.18),
                    Color(red: 0.08, green: 0.06, blue: 0.22),
                    Color(red: 0.04, green: 0.05, blue: 0.14)
                ]
            )
            .opacity(0.8)
        }
    }

    private var headerArea: some View {
        VStack(spacing: 10) {
            HStack {
                Text(dateLabel)
                    .font(.caption.weight(.heavy))
                    .tracking(1)
                    .foregroundStyle(.white.opacity(0.5))
                    .textCase(.uppercase)

                Spacer()
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(headline)
                        .font(.title2.weight(.black))
                        .foregroundStyle(.white)

                    if !wins.isEmpty {
                        Text("\(wins.count) win\(wins.count == 1 ? "" : "s") earned")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color(red: 0.12, green: 0.72, blue: 0.44))
                    }
                }

                Spacer()

                if !wins.isEmpty {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.12, green: 0.72, blue: 0.44),
                                        Color(red: 0.08, green: 0.62, blue: 0.52)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)

                        Text("\(wins.count)")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
            }

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.22, green: 0.48, blue: 1.0),
                            Color(red: 0.5, green: 0.32, blue: 1.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .padding(.top, 4)
        }
        .padding(.bottom, 16)
    }

    private var winsArea: some View {
        VStack(spacing: 0) {
            ForEach(Array(wins.enumerated()), id: \.element.id) { index, win in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(categoryColor(win.category).opacity(0.2))
                            .frame(width: 32, height: 32)

                        Image(systemName: win.category.icon)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(categoryColor(win.category))
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text(win.text)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                            .lineLimit(2)

                        Text(win.category.displayName)
                            .font(.caption2.weight(.heavy))
                            .foregroundStyle(categoryColor(win.category))
                    }

                    Spacer()

                    Image(systemName: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 0.12, green: 0.72, blue: 0.44))
                }
                .padding(.vertical, 8)

                if index < wins.count - 1 {
                    Rectangle()
                        .fill(.white.opacity(0.08))
                        .frame(height: 1)
                        .padding(.leading, 44)
                }
            }
        }
        .padding(.bottom, 12)
    }

    private func journalArea(_ note: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("JOURNAL")
                .font(.caption2.weight(.heavy))
                .tracking(1)
                .foregroundStyle(Color(red: 0.22, green: 0.48, blue: 1.0))

            Text(note)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))
                .lineLimit(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(.white.opacity(0.06))
        .clipShape(.rect(cornerRadius: 12))
        .padding(.bottom, 4)
    }

    private var footerArea: some View {
        HStack {
            Text("MVM Earned")
                .font(.caption2.weight(.heavy))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.25))

            Spacer()

            Image(systemName: "trophy.fill")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.25))
        }
    }

    private var calculatedHeight: CGFloat {
        var height: CGFloat = 48 + 80 + 24
        if !wins.isEmpty {
            height += CGFloat(wins.count) * 50 + 12
        }
        if let note = journalNote, !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            height += 80
        }
        height += 40
        return max(height, 300)
    }

    private func categoryColor(_ category: WinCategory) -> Color {
        category.color
    }
}
