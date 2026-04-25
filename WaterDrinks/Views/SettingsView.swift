import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var waterVM: WaterViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var showGoalEditor = false
    @State private var showReminderSettings = false
    @State private var showCupEditor = false
    @State private var showShareSheet = false

    private let goalPresets = [1500, 2000, 2500, 3000, 3500, 4000]

    var body: some View {
        NavigationStack {
            List {
                // Daily Goal
                Section {
                    ForEach(goalPresets, id: \.self) { ml in
                        Button {
                            waterVM.updateDailyGoal(ml: ml)
                        } label: {
                            HStack {
                                Text("\(ml) ml")
                                    .foregroundStyle(colorScheme == .dark ? ThemeManager.AppColors.darkText : ThemeManager.AppColors.lightText)
                                Spacer()
                                if waterVM.dailyGoal.targetMl == ml {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(ThemeManager.AppColors.primary)
                                }
                            }
                        }
                    }

                    Button {
                        showGoalEditor = true
                    } label: {
                        HStack {
                            Text("Custom Goal")
                                .foregroundStyle(ThemeManager.AppColors.primary)
                            Spacer()
                            Text("\(waterVM.dailyGoal.targetMl) ml")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Daily Goal")
                } footer: {
                    Text("Current goal: \(waterVM.dailyGoal.targetMl) ml")
                }

                // Reminders
                Section {
                    Toggle("Enable Reminders", isOn: Binding(
                        get: { waterVM.dailyGoal.reminderEnabled },
                        set: { waterVM.updateReminderSettings(enabled: $0, intervalMinutes: waterVM.dailyGoal.reminderIntervalMinutes) }
                    ))

                    if waterVM.dailyGoal.reminderEnabled {
                        Picker("Interval", selection: Binding(
                            get: { waterVM.dailyGoal.reminderIntervalMinutes },
                            set: { waterVM.updateReminderSettings(enabled: true, intervalMinutes: $0) }
                        )) {
                            Text("30 min").tag(30)
                            Text("1 hour").tag(60)
                            Text("1.5 hours").tag(90)
                            Text("2 hours").tag(120)
                        }
                    }
                } header: {
                    Text("Reminders")
                } footer: {
                    Text("Get reminded to drink water throughout the day")
                }

                // Active hours
                Section {
                    HStack {
                        Text("Start")
                        Spacer()
                        Picker("", selection: Binding(
                            get: { waterVM.dailyGoal.activeStartHour },
                            set: { waterVM.updateActiveHours(start: $0, end: waterVM.dailyGoal.activeEndHour) }
                        )) {
                            ForEach(5..<12) { hour in
                                Text("\(hour):00 AM").tag(hour)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    HStack {
                        Text("End")
                        Spacer()
                        Picker("", selection: Binding(
                            get: { waterVM.dailyGoal.activeEndHour },
                            set: { waterVM.updateActiveHours(start: waterVM.dailyGoal.activeStartHour, end: $0) }
                        )) {
                            ForEach(17..<24) { hour in
                                Text("\(hour - 12):00 PM").tag(hour)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                } header: {
                    Text("Active Hours")
                } footer: {
                    Text("Reminders will only be sent during these hours")
                }

                // Quick add cup size
                Section {
                    ForEach([100, 200, 250, 300, 350, 500], id: \.self) { size in
                        Button {
                            waterVM.updateCupSettings(
                                size: size,
                                icon: waterVM.dailyGoal.selectedCupIcon,
                                color: waterVM.dailyGoal.selectedCupColor
                            )
                        } label: {
                            HStack {
                                Image(systemName: "drop.fill")
                                    .foregroundStyle(Color(hex: waterVM.dailyGoal.selectedCupColor))
                                Text("\(size) ml")
                                    .foregroundStyle(colorScheme == .dark ? ThemeManager.AppColors.darkText : ThemeManager.AppColors.lightText)
                                Spacer()
                                if waterVM.dailyGoal.selectedCupSize == size {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(ThemeManager.AppColors.primary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Default Quick Add")
                } footer: {
                    Text("Tap the quick add button to add this amount")
                }

                // Appearance
                Section {
                    Toggle("Dark Mode", isOn: Binding(
                        get: { ThemeManager.shared.isDarkMode },
                        set: { _ in ThemeManager.shared.toggleTheme() }
                    ))
                } header: {
                    Text("Appearance")
                }

                // Data
                Section {
                    Button("Share App") {
                        showShareSheet = true
                    }

                    Button("Reset Today's Data") {
                        waterVM.todayRecord.entries.removeAll()
                        // Note: don't reset goal or achievements
                    }
                    .foregroundStyle(.orange)
                } header: {
                    Text("Data")
                }

                // About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Total Tracked")
                        Spacer()
                        Text("\(waterVM.totalWaterEver()) ml")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Days Tracked")
                        Spacer()
                        Text("\(waterVM.daysTracked()) days")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showGoalEditor) {
                GoalEditorView(currentGoal: waterVM.dailyGoal.targetMl) { newGoal in
                    waterVM.updateDailyGoal(ml: newGoal)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: ["Check out WaterDrinks - Stay hydrated and healthy! 💧"])
            }
        }
    }
}

struct GoalEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var value: Int
    let onSave: (Int) -> Void

    init(currentGoal: Int, onSave: @escaping (Int) -> Void) {
        _value = State(initialValue: currentGoal)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Daily Goal")
                    .font(.headline)

                HStack {
                    Button {
                        if value > 500 { value -= 100 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(ThemeManager.AppColors.primary)
                    }

                    Text("\(value) ml")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .frame(width: 200)

                    Button {
                        if value < 5000 { value += 100 }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(ThemeManager.AppColors.primary)
                    }
                }

                Slider(value: Binding(
                    get: { Double(value) },
                    set: { value = Int($0) }
                ), in: 500...5000, step: 100)
                .padding(.horizontal, 40)

                Button("Save") {
                    onSave(value)
                    dismiss()
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(ThemeManager.AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 40)
            }
            .padding()
            .navigationTitle("Edit Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}