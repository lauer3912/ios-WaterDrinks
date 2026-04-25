import XCTest
@testable import WaterDrinks

final class WaterDrinksTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here.
    }

    override func tearDownWithError() throws {
        // Put teardown code here.
    }

    func testWaterEntryCreation() throws {
        let entry = WaterEntry(amount: 250)
        XCTAssertEqual(entry.amount, 250)
        XCTAssertNotNil(entry.id)
    }

    func testDailyRecordProgress() throws {
        let record = DailyRecord(date: Date(), goalMl: 2000)
        XCTAssertEqual(record.progress, 0)
        XCTAssertEqual(record.totalMl, 0)
        XCTAssertFalse(record.isGoalReached)
    }
}