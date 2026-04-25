import SwiftUI

struct ContentView: View {
    @EnvironmentObject var waterVM: WaterViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "drop.fill")
                }
                .tag(0)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
                .tag(1)

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(2)

            AchievementsView()
                .tabItem {
                    Label("Badges", systemImage: "star.fill")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tint(ThemeManager.AppColors.primary)
    }
}