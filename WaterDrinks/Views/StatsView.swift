import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject var waterVM: WaterViewModel
    @Environment(\.colorScheme) private var colorScheme

    private let weekdays = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Weekly chart
                    weeklyChart

                    // Overall stats
                    overallStatsSection

                    // Weekly average card
                    weeklyAverageCard

                    // Streak section
                    streakSection
                }
                .padding()
            }
            .background(colorScheme == .dark ? ThemeManager.AppColors.darkBackground : ThemeManager.AppColors.lightBackground)
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)
                .foregroundStyle(colorScheme == .dark ? ThemeManager.AppColors.darkText : ThemeManager.AppColors.lightText)

            let weekStats = waterVM.weeklyStats(for: Date())

            if #available(iOS 17.0, *) {
                Chart(weekStats.dailyRecords.indices, id: \.self) { index in
                    let record = weekStats.dailyRecords[index]
                    let dayIndex = Calendar.current.component(.weekday, from: record.date) - 1
                    let dayName = weekdays[dayIndex % 7]

                    BarMark(
                        x: .value("Day", dayName),
                        y: .value("Amount", record.totalMl)
                    )
                    .foregroundStyle(record.isGoalReached ? ThemeManager.AppColors.success : ThemeManager.AppColors.primary)
                    .cornerRadius(6)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let ml = value.as(Int.self) {
                                Text("\(ml)")
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                    }
                }
                .frame(height: 200)
            } else {
                // Fallback for older iOS
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(weekStats.dailyRecords.indices, id: \.self) { index in
                        let record = weekStats.dailyRecords[index]
                        let dayIndex = Calendar.current.component(.weekday, from: record.date) - 1
                        let dayName = weekdays[dayIndex % 7]
                        let barHeight = CGFloat(record.totalMl) / CGFloat(waterVM.dailyGoal.targetMl) * 150

                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(record.isGoalReached ? ThemeManager.AppColors.success : ThemeManager.AppColors.primary)
                                .frame(width: 30, height: max(barHeight, 4))

                            Text(dayName)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(height: 200)
            }

            // Legend
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(ThemeManager.AppColors.primary)
                        .frame(width: 12, height: 12)
                    Text("Below goal")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(ThemeManager.AppColors.success)
                        .frame(width: 12, height: 12)
                    Text("Goal reached")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var overallStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Time Stats")
                .font(.headline)
                .foregroundStyle(colorScheme == .dark ? ThemeManager.AppColors.darkText : ThemeManager.AppColors.lightText)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                StatCard(title: "Total Water", value: "\(waterVM.totalWaterEver())", unit: "ml", icon: "drop.fill")
                StatCard(title: "Days Tracked", value: "\(waterVM.daysTracked())", unit: "days", icon: "calendar")
                StatCard(title: "Current Streak", value: "\(waterVM.currentStreak())", unit: "days", icon: "flame.fill")
                StatCard(title: "Best Streak", value: "\(bestStreak)", unit: "days", icon: "trophy.fill")
            }
        }
        .padding()
        .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var weeklyAverageCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Daily Average")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(weeklyAverage)")
                    .font(.title.bold())
                    .foregroundStyle(ThemeManager.AppColors.primary)
                Text("ml per day")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.largeTitle)
                .foregroundStyle(ThemeManager.AppColors.primary.opacity(0.5))
        }
        .padding()
        .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var streakSection: some View {
        HStack {
            Image(systemName: "flame.fill")
                .font(.title)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(waterVM.currentStreak()) Day Streak")
                    .font(.headline)
                Text(currentStreakMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if waterVM.isGoalReached {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(ThemeManager.AppColors.success)
            }
        }
        .padding()
        .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var bestStreak: Int {
        // Calculate best streak from records
        let sortedRecords = waterVM.records.sorted { $0.date < $1.date }
        var maxStreak = 0
        var currentStreak = 0

        for record in sortedRecords {
            if record.isGoalReached {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }

        return max(maxStreak, waterVM.currentStreak())
    }

    private var weeklyAverage: Int {
        let weekStats = waterVM.weeklyStats(for: Date())
        return weekStats.averageMl
    }

    private var currentStreakMessage: String {
        let streak = waterVM.currentStreak()
        if streak == 0 {
            return "Start your streak today!"
        } else if streak < 7 {
            return "\(7 - streak) days to Week Warrior!"
        } else if streak < 30 {
            return "\(30 - streak) days to Month Master!"
        } else {
            return "Keep it up, Hydration Hero!"
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(ThemeManager.AppColors.primary)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title2.bold())
                    .foregroundStyle(colorScheme == .dark ? ThemeManager.AppColors.darkText : ThemeManager.AppColors.lightText)
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(colorScheme == .dark ? ThemeManager.AppColors.darkSecondaryBG : ThemeManager.AppColors.lightSecondaryBG)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}