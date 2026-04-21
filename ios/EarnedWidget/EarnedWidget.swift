import WidgetKit
import SwiftUI

nonisolated struct EarnedEntry: TimelineEntry {
    let date: Date
    let todayWin: String?
    let streak: Int
    let earnedCount: Int
    let consistency: String
    let trend: String
}

nonisolated struct EarnedProvider: TimelineProvider {
    private static let appGroupID = "group.app.rork.earned.shared"
    private static let todayWinKey = "widget_today_win"
    private static let streakKey = "widget_streak"
    private static let earnedCountKey = "widget_earned_count"
    private static let consistencyKey = "widget_consistency"
    private static let trendKey = "widget_trend"

    func placeholder(in context: Context) -> EarnedEntry {
        EarnedEntry(
            date: .now,
            todayWin: "You showed up today",
            streak: 3,
            earnedCount: 4,
            consistency: "5/7 days",
            trend: "Trending up"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (EarnedEntry) -> Void) {
        let entry = readEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<EarnedEntry>) -> Void) {
        let entry = readEntry()
        let nextMidnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: .now)!)
        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        completion(timeline)
    }

    private func readEntry() -> EarnedEntry {
        guard let defaults = UserDefaults(suiteName: EarnedProvider.appGroupID) else {
            return EarnedEntry(date: .now, todayWin: nil, streak: 0, earnedCount: 0, consistency: "Start today", trend: "Holding steady")
        }
        return EarnedEntry(
            date: .now,
            todayWin: defaults.string(forKey: EarnedProvider.todayWinKey),
            streak: defaults.integer(forKey: EarnedProvider.streakKey),
            earnedCount: defaults.integer(forKey: EarnedProvider.earnedCountKey),
            consistency: defaults.string(forKey: EarnedProvider.consistencyKey) ?? "Start today",
            trend: defaults.string(forKey: EarnedProvider.trendKey) ?? "Holding steady"
        )
    }
}

struct EarnedWidgetSmallView: View {
    var entry: EarnedEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.green)
                Text("EARNED")
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1.5)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let win = entry.todayWin {
                Text(win)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
            } else {
                Text("Start your check-in")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack {
                if entry.streak > 0 {
                    Label("\(entry.streak)", systemImage: "flame.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.orange)
                }
                Spacer()
                if entry.earnedCount > 0 {
                    Text("\(entry.earnedCount) today")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.green)
                }
            }
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

struct EarnedWidgetMediumView: View {
    var entry: EarnedEntry

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.green)
                    Text("EARNED")
                        .font(.system(size: 11, weight: .heavy))
                        .tracking(1.5)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let win = entry.todayWin {
                    Text(win)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(3)
                } else {
                    Text("Ready for today's check-in")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            VStack(alignment: .trailing, spacing: 10) {
                if entry.streak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.orange)
                        Text("\(entry.streak)")
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundStyle(.primary)
                    }
                    Text("day streak")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(entry.consistency)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(entry.trend)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 90)
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

struct EarnedWidgetLockScreenView: View {
    var entry: EarnedEntry

    var body: some View {
        VStack(spacing: 2) {
            if entry.streak > 0 {
                Text("\(entry.streak)")
                    .font(.system(size: 22, weight: .heavy))
                Image(systemName: "flame.fill")
                    .font(.system(size: 12))
            } else {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 22))
                Text("Go")
                    .font(.system(size: 10, weight: .bold))
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

struct EarnedWidgetRectangularView: View {
    var entry: EarnedEntry

    var body: some View {
        HStack(spacing: 8) {
            if entry.streak > 0 {
                Image(systemName: "flame.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.orange)
            }
            VStack(alignment: .leading, spacing: 1) {
                if entry.streak > 0 {
                    Text("\(entry.streak)-day streak")
                        .font(.system(size: 14, weight: .bold))
                } else {
                    Text("Start your streak")
                        .font(.system(size: 14, weight: .bold))
                }
                if entry.earnedCount > 0 {
                    Text("\(entry.earnedCount) earned today")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                } else {
                    Text("Check in to earn")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

struct EarnedWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: EarnedEntry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                EarnedWidgetSmallView(entry: entry)
            case .systemMedium:
                EarnedWidgetMediumView(entry: entry)
            case .accessoryCircular:
                EarnedWidgetLockScreenView(entry: entry)
            case .accessoryRectangular:
                EarnedWidgetRectangularView(entry: entry)
            default:
                EarnedWidgetSmallView(entry: entry)
            }
        }
        .widgetURL(URL(string: "earned://today"))
    }
}

struct EarnedWidget: Widget {
    let kind: String = "EarnedWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: EarnedProvider()) { entry in
            EarnedWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Earned")
        .description("See your streak and daily wins at a glance.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular
        ])
    }
}
