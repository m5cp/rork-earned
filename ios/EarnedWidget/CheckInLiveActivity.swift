import ActivityKit
import WidgetKit
import SwiftUI

nonisolated struct CheckInActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Sendable {
        var earnedCount: Int
        var totalCards: Int
        var currentWinText: String
        var currentCategory: String
    }

    var sessionDate: String
}

struct CheckInLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CheckInActivityAttributes.self) { context in
            CheckInLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Earned")
                            .font(.headline)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.earnedCount)/\(context.state.totalCards)")
                        .font(.system(.title3, weight: .heavy))
                        .monospacedDigit()
                        .foregroundStyle(.green)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 4) {
                        ProgressView(value: Double(context.state.earnedCount), total: Double(context.state.totalCards))
                            .tint(.green)
                        Text(context.state.currentWinText)
                            .font(.subheadline.weight(.medium))
                            .lineLimit(1)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } compactTrailing: {
                Text("\(context.state.earnedCount)/\(context.state.totalCards)")
                    .font(.system(.caption, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(.green)
            } minimal: {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
    }
}

struct CheckInLockScreenView: View {
    let context: ActivityViewContext<CheckInActivityAttributes>

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.green)
                    Text("Checking In")
                        .font(.subheadline.weight(.bold))
                }

                Spacer()

                Text("\(context.state.earnedCount) of \(context.state.totalCards)")
                    .font(.subheadline.weight(.heavy))
                    .monospacedDigit()
                    .foregroundStyle(.green)
            }

            ProgressView(value: Double(context.state.earnedCount), total: Double(context.state.totalCards))
                .tint(.green)

            if !context.state.currentWinText.isEmpty {
                Text(context.state.currentWinText)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(16)
        .activityBackgroundTint(Color(.systemBackground))
    }
}
