import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var waterVM: WaterViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedYear: Int
    @State private var selectedMonth: Int

    private let monthNames = [
        "January","February","March","April","May","June",
        "July","August","September","October","November","December"
    ]

    init() {
        let now = Date()
        let calendar = Calendar.current
        _selectedYear = State(initialValue: calendar.component(.year, from: now))
        _selectedMonth = State(initialValue: calendar.component(.month, from: now))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Month navigation
                HStack {
                    Button { changeMonth(-1) } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.bold())
                            .foregroundStyle(ThemeManager.AppColors.primary)
                    }

                    Spacer()

                    Text("\(monthNames[selectedMonth - 1]) \(selectedYear)")
                        .font(.headline)

                    Spacer()

                    Button { changeMonth(1) } label: {
                        Image(systemName: "chevron.right")
                            .font(.title3.bold())
                            .foregroundStyle(ThemeManager.AppColors.primary)
                    }
                    .disabled(isCurrentMonth)
                }
                .padding()

                // Calendar grid
                VStack(spacing: 4) {
                    // Weekday headers
                    HStack(spacing: 4) {
                        ForEach(["S","M","T","W","T","F","S"], id: \.self) { day in
                            Text(day)
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }

                    // Days grid
                    let days = daysInMonth()
                    let firstWeekday = firstWeekdayOfMonth()

                    ForEach(0..<6, id: \.self) { week in
                        HStack(spacing: 4) {
                            ForEach(0..<7, id: \.self) { weekday in
                                let index = week * 7 + weekday
                                let dayNumber = index - firstWeekday + 1

                                if dayNumber >= 1 && dayNumber <= days {
                                    let dayKey = String(format: "%04d-%02d-%02d", selectedYear, selectedMonth, dayNumber)
                                    let record = getRecord(for: dayKey)

                                    CalendarDayView(
                                        day: dayNumber,
                                        progress: record?.progress ?? 0,
                                        isToday: isToday(dayNumber),
                                        isGoalReached: record?.isGoalReached ?? false
                                    )
                                } else {
                                    Color.clear
                                        .frame(height: 44)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Monthly summary
                monthlySummary
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .background(colorScheme == .dark ? ThemeManager.AppColors.darkBackground : ThemeManager.AppColors.lightBackground)
        }
    }

    private var isCurrentMonth: Bool {
        let now = Date()
        let calendar = Calendar.current
        return calendar.component(.year, from: now) == selectedYear &&
               calendar.component(.month, from: now) == selectedMonth
    }

    private func changeMonth(_ delta: Int) {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1
        if let date = Calendar.current.date(from: components) {
            let newDate = Calendar.current.date(byAdding: .month, value: delta, to: date)!
            let calendar = Calendar.current
            selectedYear = calendar.component(.year, from: newDate)
            selectedMonth = calendar.component(.month, from: newDate)
        }
    }

    private func daysInMonth() -> Int {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        if let date = Calendar.current.date(from: components) {
            return Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 30
        }
        return 30
    }

    private func firstWeekdayOfMonth() -> Int {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1
        if let date = Calendar.current.date(from: components) {
            let weekday = Calendar.current.component(.weekday, from: date)
            return weekday - 1
        }
        return 0
    }

    private func isToday(_ day: Int) -> Bool {
        let now = Date()
        let calendar = Calendar.current
        return calendar.component(.year, from: now) == selectedYear &&
               calendar.component(.month, from: now) == selectedMonth &&
               calendar.component(.day, from: now) == day
    }

    private func getRecord(for dayKey: String) -> DailyRecord? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dayKey) else { return nil }
        return waterVM.records.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    private var monthlySummary: some View {
        VStack(spacing: 8) {
            Divider()
            let monthRecords = waterVM.records.filter { record in
                let calendar = Calendar.current
                return calendar.component(.year, from: record.date) == selectedYear &&
                       calendar.component(.month, from: record.date) == selectedMonth
            }
            let totalMl = monthRecords.reduce(0) { $0 + $1.totalMl }
            let daysTracked = monthRecords.count
            let daysGoalReached = monthRecords.filter { $0.isGoalReached }.count

            HStack {
                VStack(alignment: .leading) {
                    Text("Monthly Summary")
                        .font(.headline)
                    Text("\(monthNames[selectedMonth - 1]) \(selectedYear)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(totalMl)")
                        .font(.title2.bold())
                        .foregroundStyle(ThemeManager.AppColors.primary)
                    Text("ml total")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)

            HStack(spacing: 20) {
                SummaryItem(value: "\(daysTracked)", label: "Days Tracked")
                SummaryItem(value: "\(daysGoalReached)", label: "Goals Reached")
                SummaryItem(value: "\(daysTracked > 0 ? Int(Double(daysGoalReached) / Double(daysTracked) * 100) : 0)%", label: "Success Rate")
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}

struct CalendarDayView: View {
    let day: Int
    let progress: Double
    let isToday: Bool
    let isGoalReached: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
                .frame(height: 44)

            if progress > 0 {
                RoundedRectangle(cornerRadius: 8)
                    .fill(progressColor)
                    .frame(height: 44)
            }

            Text("\(day)")
                .font(.subheadline)
                .foregroundStyle(textColor)

            if isToday {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(ThemeManager.AppColors.primary, lineWidth: 2)
                    .frame(height: 44)
            }
        }
    }

    private var backgroundColor: Color {
        if progress > 0 { return .clear }
        return Color(.systemGray6)
    }

    private var progressColor: Color {
        if isGoalReached {
            return ThemeManager.AppColors.success.opacity(0.7)
        }
        return ThemeManager.AppColors.primary.opacity(0.5)
    }

    private var textColor: Color {
        if progress > 0 {
            return .white
        }
        return .primary
    }
}

struct SummaryItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}