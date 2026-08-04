import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                readinessCard
                knowledgeShieldCard
                statsRow
            }
            .padding(20)
        }
        .screenBackground()
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.muted)
                Text(appState.shortName)
                    .font(AppTypography.serifTitle(34))
                    .foregroundStyle(.white)
            }
            Spacer()
            ProfileAvatar(imageData: appState.profileImageData, name: appState.firstName, size: 48)
        }
    }

    private var readinessCard: some View {
        DarkCard {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(AppColors.cardElevated, lineWidth: 8)
                        .frame(width: 72, height: 72)
                    Circle()
                        .trim(from: 0, to: CGFloat(appState.readinessPercent) / 100)
                        .stroke(AppColors.teal, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 72, height: 72)
                    Text("READY")
                        .font(.caption2.bold())
                        .foregroundStyle(AppColors.teal)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("READINESS STATUS")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppColors.teal)
                    Text("\(appState.readinessPercent)%")
                        .font(AppTypography.serifHeadline(28))
                        .foregroundStyle(.white)
                    Text("Based on quiz accuracy and completed preparation checklists.")
                        .font(.caption)
                        .foregroundStyle(AppColors.muted)
                }
            }
        }
    }

    private var knowledgeShieldCard: some View {
        let tier = appState.knowledgeTier
        return DarkCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(tier.badgeImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 56, height: 68)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("KNOWLEDGE SHIELD")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(AppColors.gold)
                        Text(tier.rawValue)
                            .font(AppTypography.serifHeadline(24))
                            .foregroundStyle(.white)
                        Text(tier.description)
                            .font(.caption)
                            .foregroundStyle(AppColors.muted)
                    }
                }

                HStack(spacing: 8) {
                    ForEach(KnowledgeTier.allCases, id: \.self) { item in
                        Text(item.rawValue)
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(item == tier ? AppColors.gold.opacity(0.15) : AppColors.cardElevated)
                            .overlay {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(item == tier ? AppColors.gold : .clear, lineWidth: 1)
                            }
                            .clipShape(Capsule())
                            .foregroundStyle(item == tier ? AppColors.gold : AppColors.muted)
                    }
                }
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(icon: "target", value: "\(appState.quizAccuracyPercent)%", label: "Accuracy", color: AppColors.teal)
            statCard(icon: "chart.line.uptrend.xyaxis", value: "$\(formattedBalance)", label: "Balance", color: AppColors.gold)
            statCard(icon: "bolt.fill", value: "\(appState.quizStreakDays) days", label: "Streak", color: AppColors.streakRed)
        }
    }

    private func statCard(icon: String, value: String, label: String, color: Color) -> some View {
        DarkCard {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(value)
                    .font(AppTypography.serifHeadline(20))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(AppColors.muted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning,"
        case 12..<17: return "Good afternoon,"
        default: return "Good evening,"
        }
    }

    private var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: appState.virtualBalance)) ?? "\(appState.virtualBalance)"
    }
}
