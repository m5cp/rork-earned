import SwiftUI

struct RingDetailView: View {
    let viewModel: EarnedViewModel
    let date: Date
    @Environment(\.dismiss) private var dismiss

    private var isToday: Bool { Calendar.current.isDateInToday(date) }
    private var rings: ReflectionRings { viewModel.rings(for: date) }

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = isToday ? "'Today' · MMMM d" : "EEEE, MMMM d"
        return formatter.string(from: date)
    }

    private var summaryLine: String {
        let closed = rings.closedCount
        if closed == 3 { return "Perfect day — all rings closed" }
        return "\(closed) of 3 rings closed"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    VStack(spacing: 6) {
                        Text(dateLabel)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(summaryLine)
                            .font(.title3.weight(.bold))
                    }
                    .padding(.top, 8)

                    ReflectionRingsView(rings: rings, lineWidth: 22, spacing: 6)
                        .frame(width: 240, height: 240)
                        .padding(.vertical, 8)

                    VStack(spacing: 12) {
                        ringRow(.checkIn, progress: rings.checkIn)
                        ringRow(.reflect, progress: rings.reflect)
                        ringRow(.mood, progress: rings.mood)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Rings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.body.weight(.semibold))
                }
            }
        }
    }

    private func ringRow(_ kind: RingKind, progress: Double) -> some View {
        let isClosed = progress >= 1.0
        let percent = Int(round(progress * 100))

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(kind.solidColor.opacity(0.2), lineWidth: 5)
                Circle()
                    .trim(from: 0, to: max(0, min(progress, 1)))
                    .stroke(kind.gradient, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: kind.iconName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(kind.solidColor)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 3) {
                Text(kind.title)
                    .font(.subheadline.weight(.bold))
                Text(statusText(for: kind, progress: progress))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(percent)%")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(isClosed ? kind.solidColor : .secondary)
                .monospacedDigit()
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func statusText(for kind: RingKind, progress: Double) -> String {
        let isClosed = progress >= 1.0
        switch kind {
        case .checkIn:
            if isClosed { return "Checked in" }
            if progress > 0 { return "In progress" }
            return isToday ? "Not started" : "Missed"
        case .reflect:
            if isClosed { return "Reflected" }
            if progress > 0 { return "Partial reflection" }
            return isToday ? "Not yet" : "No reflection"
        case .mood:
            if isClosed { return "Mood logged" }
            return isToday ? "Not logged" : "No mood"
        }
    }
}
