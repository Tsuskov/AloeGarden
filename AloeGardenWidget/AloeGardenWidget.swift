import WidgetKit
import SwiftUI

// Tapping any of these widgets deep-links into the app, which opens a focus
// session (handled by RootView.onOpenURL in AloeGardenApp.swift).
private let startSessionURL = URL(string: "aloegarden://startSession")!
private let appGroup = "group.aloeGarden"

// MARK: - Timeline

struct GardenEntry: TimelineEntry {
    let date: Date
    let totalMinutes: Int
    let level: Int
    let minutesInLevel: Int
    let streak: Int

    var fraction: Double { Double(minutesInLevel) / 30 }

    static let sample = GardenEntry(date: .now, totalMinutes: 42, level: 2, minutesInLevel: 12, streak: 3)
}

struct GardenProvider: TimelineProvider {
    func placeholder(in context: Context) -> GardenEntry { .sample }

    func getSnapshot(in context: Context, completion: @escaping (GardenEntry) -> Void) {
        completion(context.isPreview ? .sample : currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GardenEntry>) -> Void) {
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
        completion(Timeline(entries: [currentEntry()], policy: .after(next)))
    }

    private func currentEntry() -> GardenEntry {
        let store = UserDefaults(suiteName: appGroup)
        let totalMinutes = Int((store?.double(forKey: "totalSeconds") ?? 0) / 60)
        return GardenEntry(
            date: .now,
            totalMinutes: totalMinutes,
            level: totalMinutes / 30 + 1,
            minutesInLevel: totalMinutes % 30,
            streak: store?.integer(forKey: "streak") ?? 0
        )
    }
}

// MARK: - Entry view

struct GardenWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: GardenEntry

    var body: some View {
        content.widgetURL(startSessionURL)
    }

    @ViewBuilder private var content: some View {
        switch family {
        case .systemMedium:        MediumView(entry: entry)
        case .accessoryCircular:   CircularView(entry: entry)
        case .accessoryRectangular: RectangularView(entry: entry)
        case .accessoryInline:     InlineView(entry: entry)
        default:                   SmallView(entry: entry)
        }
    }
}

// MARK: - Home screen

private let cardBackground = LinearGradient(
    colors: [Color(hex: 0x1F2B20), Color(hex: 0x1A231C)],
    startPoint: .topLeading, endPoint: .bottomTrailing)

private struct Wordmark: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "leaf.fill").font(.system(size: 9))
            Text("ALOE GARDEN").font(.system(size: 8.5, design: .serif))
        }
        .foregroundStyle(Color(hex: 0x7E9A5C))
    }
}

private struct StartPill: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "book.fill").font(.system(size: 11))
            Text("Lesen starten").font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(Color(hex: 0xF4ECDB))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(Color(hex: 0x36492F), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct ProgressBar: View {
    var fraction: Double
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.1))
                Capsule().fill(LinearGradient(colors: [Color(hex: 0x7E9A5C), Color(hex: 0xBE6B45)],
                                              startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(4, geo.size.width * fraction))
            }
        }
        .frame(height: 6)
    }
}

struct SmallView: View {
    let entry: GardenEntry
    var body: some View {
        VStack(spacing: 4) {
            Wordmark()
            Spacer(minLength: 0)
            AloeRosette(length: 46, leafWidth: 8)
            Spacer(minLength: 0)
            Text("Level \(entry.level)")
                .font(.system(size: 13, weight: .semibold, design: .serif))
                .foregroundStyle(Color(hex: 0xE8E4D8))
            Text("\(entry.totalMinutes) Min gelesen")
                .font(.system(size: 9))
                .foregroundStyle(Color(hex: 0x9A9580))
        }
        .containerBackground(for: .widget) { cardBackground }
    }
}

struct MediumView: View {
    let entry: GardenEntry
    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 6) {
                AloeRosette(length: 58, leafWidth: 11)
                Text("Level \(entry.level)")
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundStyle(Color(hex: 0xE8E4D8))
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 8) {
                Wordmark()
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(entry.totalMinutes) Min")
                        .font(.system(size: 20, design: .serif))
                        .foregroundStyle(Color(hex: 0xE8E4D8))
                    Text("\(entry.streak) Tage Serie")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(hex: 0x9A9580))
                }
                ProgressBar(fraction: entry.fraction)
                StartPill()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .containerBackground(for: .widget) { cardBackground }
    }
}

// MARK: - Lock screen

struct CircularView: View {
    let entry: GardenEntry
    var body: some View {
        Gauge(value: entry.fraction) {
            Image(systemName: "book.fill")
        } currentValueLabel: {
            Text("\(entry.level)")
        }
        .gaugeStyle(.accessoryCircular)
        .containerBackground(.clear, for: .widget)
    }
}

struct RectangularView: View {
    let entry: GardenEntry
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "book.fill").font(.title3).widgetAccentable()
            VStack(alignment: .leading, spacing: 1) {
                Text("Lesen starten").font(.headline)
                Text("Level \(entry.level) · \(entry.totalMinutes) Min").font(.caption2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .containerBackground(.clear, for: .widget)
    }
}

struct InlineView: View {
    let entry: GardenEntry
    var body: some View {
        Label("Lesen · Level \(entry.level)", systemImage: "leaf.fill")
            .containerBackground(.clear, for: .widget)
    }
}

// MARK: - Configuration

struct AloeGardenWidget: Widget {
    let kind = "AloeGardenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GardenProvider()) { entry in
            GardenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Aloe Garden")
        .description("Starte eine Lese-Session und sieh deinen Garten wachsen.")
        .supportedFamilies([.systemSmall, .systemMedium,
                            .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) { AloeGardenWidget() } timeline: { GardenEntry.sample }
#Preview("Medium", as: .systemMedium) { AloeGardenWidget() } timeline: { GardenEntry.sample }
#Preview("Circular", as: .accessoryCircular) { AloeGardenWidget() } timeline: { GardenEntry.sample }
#Preview("Rectangular", as: .accessoryRectangular) { AloeGardenWidget() } timeline: { GardenEntry.sample }
#Preview("Inline", as: .accessoryInline) { AloeGardenWidget() } timeline: { GardenEntry.sample }
