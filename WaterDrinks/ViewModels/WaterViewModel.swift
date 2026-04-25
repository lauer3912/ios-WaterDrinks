import Foundation

class WaterViewModel: ObservableObject {
    @Published var dailyGoal: DailyGoal
    @Published var todayRecord: DailyRecord
    @Published var records: [DailyRecord] = []
    @Published var achievements: [Achievement] = []
    @Published var selectedCupSize: Int

    private let userDefaults = UserDefaults.standard
    private let recordsKey = "WaterDrinks_records"
    private let goalKey = "WaterDrinks_goal"
    private let achievementsKey = "WaterDrinks_achievements"

    init() {
        // Load saved goal or use default
        if let data = UserDefaults.standard.data(forKey: "WaterDrinks_goal"),
           let savedGoal = try? JSONDecoder().decode(DailyGoal.self, from: data) {
            self.dailyGoal = savedGoal
        } else {
            self.dailyGoal = DailyGoal.defaultGoal
        }

        self.selectedCupSize = dailyGoal.selectedCupSize

        // Load today's record
        let today = Calendar.current.startOfDay(for: Date())
        if let savedRecords = self.loadRecords(),
           let todayRecord = savedRecords.first(where: {
               Calendar.current.isDate($0.date, inSameDayAs: today)
           }) {
            self.todayRecord = todayRecord
            self.records = savedRecords
        } else {
            self.todayRecord = DailyRecord(date: today, goalMl: dailyGoal.targetMl)
            self.records = []
        }

        // Load achievements
        self.achievements = self.loadAchievements()

        // Initialize default achievements if first launch
        if achievements.isEmpty {
            self.achievements = Self.defaultAchievements
            saveAchievements()
        }
    }

    // MARK: - Water Intake Actions

    func addWater(amount: Int, note: String? = nil) {
        let entry = WaterEntry(amount: amount, note: note)
        todayRecord.entries.append(entry)
        saveRecords()
        checkAchievements()
    }

    func addQuickWater() {
        addWater(amount: selectedCupSize)
    }

    func removeLastEntry() {
        if !todayRecord.entries.isEmpty {
            todayRecord.entries.removeLast()
            saveRecords()
        }
    }

    // MARK: - Computed Properties

    var todayTotalMl: Int {
        todayRecord.totalMl
    }

    var todayProgress: Double {
        todayRecord.progress
    }

    var remainingMl: Int {
        max(0, dailyGoal.targetMl - todayTotalMl)
    }

    var todayPercentage: Int {
        Int(todayProgress * 100)
    }

    var isGoalReached: Bool {
        todayRecord.isGoalReached
    }

    // MARK: - Goal Management

    func updateDailyGoal(ml: Int) {
        dailyGoal.targetMl = ml
        todayRecord.goalMl = ml
        saveGoal()
        saveRecords()
    }

    func updateReminderSettings(enabled: Bool, intervalMinutes: Int) {
        dailyGoal.reminderEnabled = enabled
        dailyGoal.reminderIntervalMinutes = intervalMinutes
        saveGoal()
    }

    func updateActiveHours(start: Int, end: Int) {
        dailyGoal.activeStartHour = start
        dailyGoal.activeEndHour = end
        saveGoal()
    }

    func updateCupSettings(size: Int, icon: String, color: String) {
        selectedCupSize = size
        dailyGoal.selectedCupSize = size
        dailyGoal.selectedCupIcon = icon
        dailyGoal.selectedCupColor = color
        saveGoal()
    }

    // MARK: - History & Stats

    func recordsForWeek(startDate: Date) -> [DailyRecord] {
        let calendar = Calendar.current
        return records.filter { record in
            calendar.isDate(record.date, equalTo: startDate, toGranularity: .weekOfYear)
        }
    }

    func weeklyStats(for date: Date) -> WeeklyStats {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        let weekRecords = recordsForWeek(startDate: weekStart)

        // Fill in missing days with empty records
        var completeRecords: [DailyRecord] = []
        for i in 0..<7 {
            let day = calendar.date(byAdding: .day, value: i, to: weekStart)!
            if let existing = weekRecords.first(where: { Calendar.current.isDate($0.date, inSameDayAs: day) }) {
                completeRecords.append(existing)
            } else {
                completeRecords.append(DailyRecord(date: day, goalMl: dailyGoal.targetMl))
            }
        }

        return WeeklyStats(weekStartDate: weekStart, dailyRecords: completeRecords)
    }

    func currentStreak() -> Int {
        let sortedRecords = records.sorted { $0.date > $1.date }
        var streak = 0

        for record in sortedRecords {
            if record.isGoalReached {
                streak += 1
            } else {
                break
            }
        }

        // Check if today is not yet complete, still count streak from yesterday
        if streak == 0 && sortedRecords.first?.isGoalReached == true {
            return 1
        }

        return streak
    }

    func totalWaterEver() -> Int {
        records.reduce(0) { $0 + $1.totalMl }
    }

    func daysTracked() -> Int {
        records.count
    }

    // MARK: - Achievements

    func checkAchievements() {
        var updated = false

        for i in 0..<achievements.count {
            let oldValue = achievements[i].currentValue

            switch achievements[i].type {
            case .streak:
                achievements[i] = Achievement(
                    id: achievements[i].id,
                    name: achievements[i].name,
                    description: achievements[i].description,
                    icon: achievements[i].icon,
                    requiredValue: achievements[i].requiredValue,
                    type: achievements[i].type,
                    currentValue: currentStreak()
                )
            case .total:
                achievements[i] = Achievement(
                    id: achievements[i].id,
                    name: achievements[i].name,
                    description: achievements[i].description,
                    icon: achievements[i].icon,
                    requiredValue: achievements[i].requiredValue,
                    type: achievements[i].type,
                    currentValue: totalWaterEver() / 1000 // in liters
                )
            case .daily:
                achievements[i] = Achievement(
                    id: achievements[i].id,
                    name: achievements[i].name,
                    description: achievements[i].description,
                    icon: achievements[i].icon,
                    requiredValue: achievements[i].requiredValue,
                    type: achievements[i].type,
                    currentValue: daysTracked()
                )
            case .consecutive:
                achievements[i] = Achievement(
                    id: achievements[i].id,
                    name: achievements[i].name,
                    description: achievements[i].description,
                    icon: achievements[i].icon,
                    requiredValue: achievements[i].requiredValue,
                    type: achievements[i].type,
                    currentValue: currentStreak()
                )
            }

            if achievements[i].currentValue != oldValue {
                updated = true
            }
        }

        if updated {
            saveAchievements()
        }
    }

    var unlockedAchievements: [Achievement] {
        achievements.filter { $0.isUnlocked }
    }

    var lockedAchievements: [Achievement] {
        achievements.filter { !$0.isUnlocked }
    }

    // MARK: - Persistence

    private func saveRecords() {
        var allRecords = records.filter { !Calendar.current.isDate($0.date, inSameDayAs: todayRecord.date) }
        allRecords.append(todayRecord)

        if let data = try? JSONEncoder().encode(allRecords) {
            userDefaults.set(data, forKey: recordsKey)
        }
        records = allRecords
    }

    private func loadRecords() -> [DailyRecord]? {
        guard let data = userDefaults.data(forKey: recordsKey) else { return nil }
        return try? JSONDecoder().decode([DailyRecord].self, from: data)
    }

    private func saveGoal() {
        if let data = try? JSONEncoder().encode(dailyGoal) {
            userDefaults.set(data, forKey: goalKey)
        }
    }

    private func saveAchievements() {
        // Save current values for each achievement type
        var achievementData: [[String: Any]] = []
        for a in achievements {
            achievementData.append([
                "id": a.id.uuidString,
                "currentValue": a.currentValue
            ])
        }
        userDefaults.set(achievementData, forKey: achievementsKey)
    }

    private func loadAchievements() -> [Achievement] {
        var result = Self.defaultAchievements

        if let data = userDefaults.array(forKey: achievementsKey) as? [[String: Any]] {
            for item in data {
                if let idString = item["id"] as? String,
                   let uuid = UUID(uuidString: idString),
                   let currentValue = item["currentValue"] as? Int,
                   let index = result.firstIndex(where: { $0.id == uuid }) {
                    result[index] = Achievement(
                        id: result[index].id,
                        name: result[index].name,
                        description: result[index].description,
                        icon: result[index].icon,
                        requiredValue: result[index].requiredValue,
                        type: result[index].type,
                        currentValue: currentValue
                    )
                }
            }
        }

        return result
    }

    // MARK: - Default Achievements

    static let defaultAchievements: [Achievement] = [
        // Streak achievements
        Achievement(id: UUID(), name: "First Step", description: "Complete your first day", icon: "star.fill", requiredValue: 1, type: .streak, currentValue: 0),
        Achievement(id: UUID(), name: "Week Warrior", description: "7-day streak", icon: "flame.fill", requiredValue: 7, type: .streak, currentValue: 0),
        Achievement(id: UUID(), name: "Month Master", description: "30-day streak", icon: "crown.fill", requiredValue: 30, type: .streak, currentValue: 0),
        Achievement(id: UUID(), name: "Century Club", description: "100-day streak", icon: "trophy.fill", requiredValue: 100, type: .streak, currentValue: 0),

        // Total water achievements
        Achievement(id: UUID(), name: "First Liter", description: "Drink 1 liter total", icon: "drop.fill", requiredValue: 1, type: .total, currentValue: 0),
        Achievement(id: UUID(), name: "10 Liters", description: "Drink 10 liters total", icon: "drop.2.fill", requiredValue: 10, type: .total, currentValue: 0),
        Achievement(id: UUID(), name: "100 Liters", description: "Drink 100 liters total", icon: "drop.3.fill", requiredValue: 100, type: .total, currentValue: 0),

        // Daily tracking achievements
        Achievement(id: UUID(), name: "Day One", description: "Track for 1 day", icon: "calendar", requiredValue: 1, type: .daily, currentValue: 0),
        Achievement(id: UUID(), name: "Week Tracker", description: "Track for 7 days", icon: "calendar.badge.checkmark", requiredValue: 7, type: .daily, currentValue: 0),
        Achievement(id: UUID(), name: "Month Tracker", description: "Track for 30 days", icon: "calendar.circle", requiredValue: 30, type: .daily, currentValue: 0),

        // Special achievements
        Achievement(id: UUID(), name: "Perfect Day", description: "Reach 100% of daily goal", icon: "checkmark.seal.fill", requiredValue: 1, type: .consecutive, currentValue: 0),
        Achievement(id: UUID(), name: "Hydration Hero", description: "Reach 200% of daily goal", icon: "bolt.fill", requiredValue: 200, type: .consecutive, currentValue: 0)
    ]
}