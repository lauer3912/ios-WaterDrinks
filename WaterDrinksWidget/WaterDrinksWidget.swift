import WidgetKit
import SwiftUI

@main
struct WaterDrinksWidgetBundle: WidgetBundle {
    var body: some Widget {
        WaterDrinksWidget()
    }
}

struct WaterDrinksWidget: Widget {
    let kind: String = "WaterDrinksWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WaterDrinksWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Water Tracker")
        .description("Track your daily water intake.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), currentMl: 1500, goalMl: 2000, percentage: 75)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), currentMl: 1500, goalMl: 2000, percentage: 75)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        // Load actual data from shared UserDefaults (App Groups)
        let userDefaults = UserDefaults(suiteName: "group.com.ggsheng.WaterDrinks")
        let today = Calendar.current.startOfDay(for: Date())

        // Try to get today's data
        var currentMl = 0
        var goalMl = 2000

        if let data = userDefaults?.data(forKey: "today_ml") {
            currentMl = (try? JSONDecoder().decode(Int.self, from: data)) ?? 0
        }
        if let data = userDefaults?.data(forKey: "goal_ml") {
            goalMl = (try? JSONDecoder().decode(Int.self, from: data)) ?? 2000
        }

        let percentage = goalMl > 0 ? Int((Double(currentMl) / Double(goalMl)) * 100) : 0

        let entry = SimpleEntry(date: Date(), currentMl: currentMl, goalMl: goalMl, percentage: percentage)

        // Update every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let currentMl: Int
    let goalMl: Int
    let percentage: Int
}

struct WaterDrinksWidgetEntryView: View {
    var entry: Provider.Entry

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            if colorScheme == .dark {
                Color(hex: "#1A2A44")
            } else {
                Color(hex: "#F5F9FF")
            }

            VStack(spacing: 8) {
                // Drop icon
                Image(systemName: "drop.fill")
                    .font(.title2)
                    .foregroundStyle(Color(hex: "#3D9AFD"))

                // Progress text
                Text("\(entry.currentMl)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#3D9AFD"))

                Text("/ \(entry.goalMl) ml")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Percentage
                Text("\(entry.percentage)%")
                    .font(.caption.bold())
                    .foregroundStyle(entry.percentage >= 100 ? Color(hex: "#34C759") : Color(hex: "#3D9AFD"))

                if entry.percentage >= 100 {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color(hex: "#34C759"))
                }
            }
            .padding()
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}