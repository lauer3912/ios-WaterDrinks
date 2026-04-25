import XCTest

final class WaterDrinksUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    func testAppLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Check home tab is visible
        XCTAssertTrue(app.tabBars.buttons["Home"].exists)
    }
}