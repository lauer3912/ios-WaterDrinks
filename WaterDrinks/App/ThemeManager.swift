import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "WaterDrinks_isDarkMode")
        }
    }

    var colorScheme: ColorScheme? {
        isDarkMode ? .dark : .light
    }

    struct AppColors {
        // Primary water blue
        static let primary = Color(hex: "#3D9AFD")
        static let primaryLight = Color(hex: "#7CB8FF")
        static let primaryDark = Color(hex: "#0066CC")

        // Backgrounds
        static let lightBackground = Color(hex: "#F5F9FF")
        static let darkBackground = Color(hex: "#0A1628")

        // Card backgrounds
        static let lightCard = Color(hex: "#FFFFFF")
        static let darkCard = Color(hex: "#1A2A44")

        // Secondary backgrounds
        static let lightSecondaryBG = Color(hex: "#E8F4FF")
        static let darkSecondaryBG = Color(hex: "#243352")

        // Text colors
        static let lightText = Color(hex: "#1A1A2E")
        static let darkText = Color(hex: "#FFFFFF")

        static let lightSecondaryText = Color(hex: "#6B7280")
        static let darkSecondaryText = Color(hex: "#9CA3AF")

        // Success / Achievement colors
        static let success = Color(hex: "#34C759")
        static let gold = Color(hex: "#FFD700")
        static let silver = Color(hex: "#C0C0C0")
        static let bronze = Color(hex: "#CD7F32")

        // Cup color options
        static let cupColors = [
            "#3D9AFD", // Blue (default)
            "#34C759", // Green
            "#FF9500", // Orange
            "#FF3B30", // Red
            "#AF52DE", // Purple
            "#FF2D55", // Pink
            "#00C7BE", // Teal
            "#5856D6"  // Indigo
        ]

        // Water drop icons
        static let dropIcons = ["drop.fill", "drop", "humidity.fill", "cloud.rain.fill", "aqi.medium"]

        // Motivational messages
        static let motivationalMessages = [
            "Stay hydrated, stay healthy!",
            "Every drop counts!",
            "You're doing great!",
            "Keep going!",
            "Hydration is key!",
            "Your body will thank you!",
            "Water is life!",
            "Keep it up!"
        ]
    }

    private init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "WaterDrinks_isDarkMode")
    }

    func toggleTheme() {
        isDarkMode.toggle()
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
        case 8:
            (r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF)
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

    var hexString: String {
        guard let components = UIColor(self).cgColor.components else { return "#3D9AFD" }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}