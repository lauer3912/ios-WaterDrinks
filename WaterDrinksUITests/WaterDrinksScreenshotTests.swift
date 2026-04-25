import XCTest

final class WaterDrinksScreenshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--screenshot-mode"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helper Functions

    func ss(_ name: String) {
        let data = app.windows.firstMatch.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: "/tmp/WaterDrinks_\(name).png"))
    }

    // MARK: - iPhone Screenshots (5 tabs)

    func testHomeScreen() throws {
        ss("iPhone_Home")
    }

    func testHistoryScreen() throws {
        // Navigate to History tab
        if app.tabBars.buttons["History"].exists {
            app.tabBars.buttons["History"].tap()
        }
        ss("iPhone_History")
    }

    func testStatsScreen() throws {
        // Navigate to Stats tab
        if app.tabBars.buttons["Stats"].exists {
            app.tabBars.buttons["Stats"].tap()
        }
        ss("iPhone_Stats")
    }

    func testAchievementsScreen() throws {
        // Navigate to Badges tab
        if app.tabBars.buttons["Badges"].exists {
            app.tabBars.buttons["Badges"].tap()
        }
        ss("iPhone_Achievements")
    }

    func testSettingsScreen() throws {
        // Navigate to Settings tab
        if app.tabBars.buttons["Settings"].exists {
            app.tabBars.buttons["Settings"].tap()
        }
        ss("iPhone_Settings")
    }

    // MARK: - Quick Add Interaction

    func testQuickAddInteraction() throws {
        // Navigate to Home
        if app.tabBars.buttons["Home"].exists {
            app.tabBars.buttons["Home"].tap()
        }
        
        // Try to tap a quick add button if visible
        // The exact button labels may vary based on the UI
        ss("iPhone_Home_WithInteraction")
    }
}