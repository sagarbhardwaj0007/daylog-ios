import WidgetKit
import SwiftUI

// MARK: - Shared data reader

private struct WidgetData {
    let streak: Int
    let journaledToday: Bool

    /// Reads values written by JournalStore.syncWidgetData().
    /// Requires App Groups "group.Sagar.Journal" enabled on both targets.
    static func read() -> WidgetData {
        let defaults = UserDefaults(suiteName: "group.Sagar.Journal") ?? .standard
        return WidgetData(
            streak: defaults.integer(forKey: "daylog_streak"),
            journaledToday: defaults.bool(forKey: "daylog_journaledToday")
        )
    }
}

// MARK: - Timeline entry

struct DaylogEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let journaledToday: Bool
}

// MARK: - Provider

struct DaylogProvider: TimelineProvider {
    func placeholder(in context: Context) -> DaylogEntry {
        DaylogEntry(date: Date(), streak: 5, journaledToday: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (DaylogEntry) -> Void) {
        let data = WidgetData.read()
        completion(DaylogEntry(date: Date(), streak: data.streak, journaledToday: data.journaledToday))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DaylogEntry>) -> Void) {
        let data = WidgetData.read()
        let entry = DaylogEntry(date: Date(), streak: data.streak, journaledToday: data.journaledToday)
        // Refresh just after midnight so "journaled today" status resets automatically
        let nextMidnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86_400))
        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }
}

// MARK: - Small widget (systemSmall)

struct DaylogSmallView: View {
    let entry: DaylogEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("🔥")
                Text("\(entry.streak)")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(entry.streak > 0 ? Color.orange : Color.secondary)
            }
            Text("day streak")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Label(
                entry.journaledToday ? "Done today" : "Write today",
                systemImage: entry.journaledToday ? "checkmark.circle.fill" : "pencil.circle"
            )
            .font(.caption.weight(.semibold))
            .foregroundStyle(entry.journaledToday ? .green : .orange)
        }
        .padding()
        .containerBackground(Color(.systemBackground), for: .widget)
        .widgetURL(URL(string: "daylog://open"))
    }
}

// MARK: - Medium widget (systemMedium)

struct DaylogMediumView: View {
    let entry: DaylogEntry

    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("🔥")
                    Text("\(entry.streak)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(entry.streak > 0 ? Color.orange : Color.secondary)
                }
                Text("day streak")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: entry.journaledToday ? "checkmark.circle.fill" : "pencil.circle")
                    .font(.title)
                    .foregroundStyle(entry.journaledToday ? .green : .orange)
                Text(entry.journaledToday ? "Done today" : "Write today")
                    .font(.headline)
                Text(entry.journaledToday ? "Great job!" : "Keep the streak going")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .containerBackground(Color(.systemBackground), for: .widget)
        .widgetURL(URL(string: "daylog://new"))
    }
}

// MARK: - Widget configurations

struct DaylogSmallWidget: Widget {
    let kind = "DaylogSmallWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DaylogProvider()) { DaylogSmallView(entry: $0) }
            .configurationDisplayName("Daylog")
            .description("Your daily journaling streak.")
            .supportedFamilies([.systemSmall])
    }
}

struct DaylogMediumWidget: Widget {
    let kind = "DaylogMediumWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DaylogProvider()) { DaylogMediumView(entry: $0) }
            .configurationDisplayName("Daylog")
            .description("Your daily journaling streak.")
            .supportedFamilies([.systemMedium])
    }
}
