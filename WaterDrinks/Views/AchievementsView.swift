import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var waterVM: WaterViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Progress summary
                    progressSummary

                    // Unlocked achievements
                    if !waterVM.unlockedAchievements.isEmpty {
                        unlockedSection
                    }

                    // Locked achievements
                    if !waterVM.lockedAchievements.isEmpty {
                        lockedSection
                    }
                }
                .padding()
            }
            .background(colorScheme == .dark ? ThemeManager.AppColors.darkBackground : ThemeManager.AppColors.lightBackground)
            .navigationTitle("Badges")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var progressSummary: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Achievement Progress")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(waterVM.unlockedAchievements.count) / \(waterVM.achievements.count)")
                    .font(.title.bold())
                    .foregroundStyle(ThemeManager.AppColors.primary)
            }

            Spacer()

            ZStack {
                Circle()
                    .stroke(colorScheme == .dark ? ThemeManager.AppColors.darkSecondaryBG : ThemeManager.AppColors.lightSecondaryBG, lineWidth: 8)
                    .frame(width: 60, height: 60)

                Circle()
                    .trim(from: 0, to: progressPercentage)
                    .stroke(ThemeManager.AppColors.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))

                Text("\(Int(progressPercentage * 100))%")
                    .font(.caption.bold())
            }
        }
        .padding()
        .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var unlockedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Unlocked")
                .font(.headline)
                .foregroundStyle(colorScheme == .dark ? ThemeManager.AppColors.darkText : ThemeManager.AppColors.lightText)

            ForEach(waterVM.unlockedAchievements) { achievement in
                AchievementRow(achievement: achievement, isUnlocked: true)
            }
        }
    }

    private var lockedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Locked")
                .font(.headline)
                .foregroundStyle(colorScheme == .dark ? ThemeManager.AppColors.darkText : ThemeManager.AppColors.lightText)

            ForEach(waterVM.lockedAchievements) { achievement in
                AchievementRow(achievement: achievement, isUnlocked: false)
            }
        }
    }

    private var progressPercentage: Double {
        guard !waterVM.achievements.isEmpty else { return 0 }
        return Double(waterVM.unlockedAchievements.count) / Double(waterVM.achievements.count)
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    let isUnlocked: Bool

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? achievementColor.opacity(0.2) : Color(.systemGray5))
                    .frame(width: 50, height: 50)

                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundStyle(isUnlocked ? achievementColor : .secondary)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.name)
                    .font(.headline)
                    .foregroundStyle(isUnlocked ? (colorScheme == .dark ? ThemeManager.AppColors.darkText : ThemeManager.AppColors.lightText) : .secondary)

                Text(achievement.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !isUnlocked {
                    ProgressView(value: achievement.progress)
                        .tint(ThemeManager.AppColors.primary)
                        .scaleEffect(y: 0.8)

                    Text("\(achievement.currentValue) / \(achievement.requiredValue)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Badge indicator
            if isUnlocked {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(ThemeManager.AppColors.success)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(colorScheme == .dark ? ThemeManager.AppColors.darkCard : ThemeManager.AppColors.lightCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(isUnlocked ? 1 : 0.8)
    }

    private var achievementColor: Color {
        switch achievement.type {
        case .streak:
            return .orange
        case .total:
            return ThemeManager.AppColors.primary
        case .daily:
            return .green
        case .consecutive:
            return .purple
        }
    }
}