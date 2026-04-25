import SwiftUI

struct HomeView: View {
    @EnvironmentObject var waterVM: WaterViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var showAddWater = false
    @State private var showCustomAmount = false
    @State private var customAmount = ""

    private let quickAmounts = [100, 200, 250, 300, 350, 500]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Main progress circle
                    progressCircle

                    // Quick add buttons
                    quickAddSection

                    // Today's entries
                    todayEntriesSection
                }
                .padding()
            }
            .background(colorScheme == .dark ? ThemeManager.AppColors.darkBackground : ThemeManager.AppColors.lightBackground)
            .navigationTitle("WaterDrinks")
            .sheet(isPresented: $showAddWater) {
                AddWaterView()
            }
            .sheet(isPresented: $showCustomAmount) {
                CustomAmountView(customAmount: $customAmount) { amount in
                    if amount > 0 {
                        waterVM.addWater(amount: amount)
                    }
                    customAmount = ""
                }
            }
        }
    }

    private var progressCircle: some View {
        VStack(spacing: 16) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(
                        colorScheme == .dark ? ThemeManager.AppColors.darkSecondaryBG : ThemeManager.AppColors.lightSecondaryBG,
                        lineWidth: 20
                    )

                // Progress circle
                Circle()
                    .trim(from: 0, to: waterVM.todayProgress)
                    .stroke(
                        waterVM.isGoalReached ? ThemeManager.AppColors.success : ThemeManager.AppColors.primary,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: waterVM.todayProgress)

                // Center content
                VStack(spacing: 8) {
                    if waterVM.isGoalReached {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(ThemeManager.AppColors.success)
                        Text("Goal Reached!")
                            .font(.headline)
                            .foregroundStyle(ThemeManager.AppColors.success)
                    } else {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(ThemeManager.AppColors.primary)

                        Text("\(waterVM.todayTotalMl)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(colorScheme == .dark ? ThemeManager.AppColors.darkText : ThemeManager.AppColors.lightText)

                        Text("of \(waterVM.dailyGoal.targetMl) ml")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Text("\(waterVM.todayPercentage)%")
                        .font(.title3.bold())
                        .foregroundStyle(ThemeManager.AppColors.primary)
                }
            }
            .frame(width: 250, height: 250)

            // Motivational message
            if !waterVM.isGoalReached {
                Text(ThemeManager.AppColors.motivationalMessages.randomElement() ?? "Stay hydrated!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }

    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Add")
                .font(.headline)
                .foregroundStyle(colorScheme == .dark ? ThemeManager.AppColors.darkText : ThemeManager.AppColors.lightText)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(quickAmounts, id: \.self) { amount in
                    QuickAddButton(amount: amount) {
                        waterVM.addWater(amount: amount)
                    }
                }

                // Custom amount button
                Button {
                    showCustomAmount = true
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(ThemeManager.AppColors.primary)
                        Text("Custom")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(colorScheme == .dark ? ThemeManager.AppColors.darkSecondaryBG : ThemeManager.AppColors.lightSecondaryBG)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var todayEntriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Log")
                    .font(.headline)
                    .foregroundStyle(colorScheme == .dark ? ThemeManager.AppColors.darkText : ThemeManager.AppColors.lightText)
                Spacer()
                if !waterVM.todayRecord.entries.isEmpty {
                    Button("Undo") {
                        waterVM.removeLastEntry()
                    }
                    .font(.caption)
                    .foregroundStyle(.red)
                }
            }

            if waterVM.todayRecord.entries.isEmpty {
                Text("No entries yet. Start tracking!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(waterVM.todayRecord.entries.reversed().prefix(5)) { entry in
                    HStack {
                        Image(systemName: "drop.fill")
                            .foregroundStyle(ThemeManager.AppColors.primary)
                        Text("\(entry.amount) ml")
                            .font(.body)
                        Spacer()
                        Text(entry.timestamp, style: .time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)

                    if entry.id != waterVM.todayRecord.entries.reversed().prefix(5).last?.id {
                        Divider()
                    }
                }

                if waterVM.todayRecord.entries.count > 5 {
                    Text("+ \(waterVM.todayRecord.entries.count - 5) more entries")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .padding()
        .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct QuickAddButton: View {
    let amount: Int
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "drop.fill")
                    .font(.title3)
                Text("\(amount)")
                    .font(.headline)
                Text("ml")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(colorScheme == .dark ? ThemeManager.AppColors.darkSecondaryBG : ThemeManager.AppColors.lightSecondaryBG)
            .foregroundStyle(ThemeManager.AppColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct AddWaterView: View {
    @EnvironmentObject var waterVM: WaterViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Amount (ml)") {
                    TextField("e.g. 250", text: $amount)
                        .keyboardType(.numberPad)
                }

                Section("Note (optional)") {
                    TextField("e.g. After workout", text: $note)
                }

                Section {
                    Button("Add Water") {
                        if let ml = Int(amount), ml > 0 {
                            waterVM.addWater(amount: ml, note: note.isEmpty ? nil : note)
                            dismiss()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .listRowBackground(ThemeManager.AppColors.primary)
                }
            }
            .navigationTitle("Add Water")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct CustomAmountView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var customAmount: String
    let onAdd: (Int) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Enter custom amount")
                    .font(.headline)

                TextField("Amount in ml", text: $customAmount)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)

                HStack(spacing: 16) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.red)

                    Button("Add") {
                        if let ml = Int(customAmount), ml > 0 {
                            onAdd(ml)
                            dismiss()
                        }
                    }
                    .foregroundStyle(ThemeManager.AppColors.primary)
                }
            }
            .padding()
        }
    }
}