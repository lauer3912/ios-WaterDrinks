import SwiftUI

@main
struct WaterDrinksApp: App {
    @StateObject private var waterVM = WaterViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(waterVM)
                .preferredColorScheme(ThemeManager.shared.colorScheme)
        }
    }
}