import Foundation

struct WaterEntry: Identifiable, Codable {
    let id: UUID
    let amount: Int // in ml
    let timestamp: Date
    let note: String?

    init(amount: Int, note: String? = nil) {
        self.id = UUID()
        self.amount = amount
        self.timestamp = Date()
        self.note = note
    }
}

struct Achievement: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let icon: String
    let requiredValue: Int
    let type: AchievementType
    let currentValue: Int

    var progress: Double {
        guard requiredValue > 0 else { return 0 }
        return min(Double(currentValue) / Double(requiredValue), 1.0)
    }

    var isUnlocked: Bool {
        currentValue >= requiredValue
    }

    enum AchievementType: String, CaseIterable {
        case streak
        case total
        case daily
        case consecutive
    }
}

struct DailyGoal: Codable {
    var targetMl: Int
    var reminderEnabled: Bool
    var reminderIntervalMinutes: Int
    var activeStartHour: Int
    var activeEndHour: Int
    var selectedCupSize: Int
    var selectedCupIcon: String
    var selectedCupColor: String

    static let defaultGoal = DailyGoal(
        targetMl: 2000,
        reminderEnabled: true,
        reminderIntervalMinutes: 60,
        activeStartHour: 8,
        activeEndHour: 22,
        selectedCupSize: 250,
        selectedCupIcon: "drop.fill",
        selectedCupColor: "#3D9AFD"
    )
}

struct DailyRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    var entries: [WaterEntry]
    var goalMl: Int

    var totalMl: Int {
        entries.reduce(0) { $0 + $1.amount }
    }

    var progress: Double {
        guard goalMl > 0 else { return 0 }
        return min(Double(totalMl) / Double(goalMl), 1.0)
    }

    var isGoalReached: Bool {
        totalMl >= goalMl
    }

    init(date: Date, goalMl: Int) {
        self.id = UUID()
        self.date = date
        self.entries = []
        self.goalMl = goalMl
    }
}

struct WeeklyStats: Identifiable {
    let id = UUID()
    let weekStartDate: Date
    let dailyRecords: [DailyRecord]

    var totalMl: Int {
        dailyRecords.reduce(0) { $0 + $1.totalMl }
    }

    var averageMl: Int {
        guard !dailyRecords.isEmpty else { return 0 }
        return totalMl / dailyRecords.count
    }

    var daysGoalReached: Int {
        dailyRecords.filter { $0.isGoalReached }.count
    }

    var streakDays: Int {
        var streak = 0
        for record in dailyRecords.reversed() {
            if record.isGoalReached {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }
}