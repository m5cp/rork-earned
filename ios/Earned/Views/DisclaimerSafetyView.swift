import SwiftUI

struct DisclaimerSafetyView: View {
    @AppStorage("disclaimerAcknowledged") private var acknowledged: Bool = false
    @State private var showCheck: Bool = false

    var body: some View {
        List {
            Section {
                Text("MVM Earned is a self-guided accountability and personal progress tracking tool designed to help you recognize daily wins and build consistency.")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .padding(.vertical, 4)
            }

            Section("What This App Is Not") {
                disclaimerRow(icon: "cross.case", color: .red, text: "Not a medical provider")
                disclaimerRow(icon: "brain.head.profile", color: .orange, text: "Not a mental health provider or therapist")
                disclaimerRow(icon: "stethoscope", color: .purple, text: "Does not provide medical advice, diagnosis, or treatment")
            }

            Section {
                Text("All content is for personal use and general well-being only. This app is not a substitute for professional care.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)

                Text("Users should seek a qualified healthcare provider for any medical or mental health concerns.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            }

            Section("Crisis Support") {
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "heart.text.clipboard")
                        .font(.title3)
                        .foregroundStyle(.red)
                        .frame(width: 28)

                    Text("If you are experiencing a mental health crisis or need immediate support, contact a qualified professional or local emergency services.")
                        .font(.subheadline)
                }
                .padding(.vertical, 6)
            }

            Section {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        acknowledged = true
                        showCheck = true
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: acknowledged ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(acknowledged ? EarnedColors.earned : .secondary)
                            .contentTransition(.symbolEffect(.replace))

                        Text("I understand")
                            .font(.body.weight(.medium))
                            .foregroundStyle(.primary)
                    }
                    .padding(.vertical, 4)
                }
            } footer: {
                Text("This acknowledgment is optional and does not affect your access to the app.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .navigationTitle("Disclaimer & Safety")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            showCheck = acknowledged
        }
    }

    private func disclaimerRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 28)

            Text(text)
                .font(.subheadline)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}
