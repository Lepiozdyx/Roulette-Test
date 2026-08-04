import PhotosUI
import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @State private var showSettings = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                statsGrid
                Text("ACHIEVEMENTS")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppColors.muted)
                achievementsGrid
            }
            .padding(20)
        }
        .screenBackground()
        .sheet(isPresented: $showSettings) {
            ProfileSettingsView()
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            ProfileAvatar(imageData: appState.profileImageData, name: appState.firstName, size: 64)

            VStack(alignment: .leading, spacing: 4) {
                Text(appState.displayName)
                    .font(AppTypography.serifHeadline(24))
                    .foregroundStyle(.white)
                Text("Advanced Learner · Level \(appState.playerLevel)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.teal)
            }

            Spacer()

            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .foregroundStyle(AppColors.muted)
                    .padding(10)
                    .background(AppColors.card)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            profileStat(icon: "target", value: "\(appState.quizAccuracyPercent)%", label: "Quiz Accuracy", color: AppColors.teal)
            profileStat(icon: "chart.line.uptrend.xyaxis", value: "\(appState.winRatePercent)%", label: "Win Rate", color: AppColors.gold)
            profileStat(icon: "bolt.fill", value: "\(appState.checklistCompletionsCount + appState.simulatorSpins / 5)", label: "Sessions", color: .purple)
            profileStat(icon: "chart.bar.fill", value: formattedROI, label: "ROI", color: AppColors.teal)
        }
    }

    private var achievementsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(AchievementID.allCases) { achievement in
                let unlocked = appState.isAchievementUnlocked(achievement)
                VStack(spacing: 8) {
                    Image(systemName: achievement.icon)
                        .font(.title2)
                        .foregroundStyle(unlocked ? AppColors.gold : AppColors.muted)
                    Text(achievement.title)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(unlocked ? AppColors.gold : AppColors.muted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(unlocked ? AppColors.gold.opacity(0.12) : AppColors.card)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(unlocked ? AppColors.gold.opacity(0.5) : .clear, lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private func profileStat(icon: String, value: String, label: String, color: Color) -> some View {
        DarkCard {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(value)
                    .font(AppTypography.serifHeadline(22))
                    .foregroundStyle(.white)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(AppColors.muted)
            }
        }
    }

    private var formattedROI: String {
        let roi = appState.roiPercent
        return roi >= 0 ? "+\(roi)%" : "\(roi)%"
    }
}

struct ProfileSettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Spacer()
                        ProfileAvatar(imageData: imageData, name: firstName.isEmpty ? "?" : firstName, size: 96)
                        Spacer()
                    }

                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("Choose Photo", systemImage: "photo.on.rectangle")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppColors.teal)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.teal, lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)

                    if imageData != nil {
                        Button("Remove Photo") {
                            imageData = nil
                            selectedPhoto = nil
                        }
                        .font(.subheadline)
                        .foregroundStyle(AppColors.muted)
                        .frame(maxWidth: .infinity)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("FIRST NAME")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(AppColors.muted)
                        TextField("First name", text: $firstName)
                            .padding(14)
                            .background(AppColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .dismissKeyboardToolbar()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("LAST NAME")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(AppColors.muted)
                        TextField("Last name", text: $lastName)
                            .padding(14)
                            .background(AppColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .dismissKeyboardToolbar()
                    }
                }
                .padding(20)
            }
            .screenBackground()
            .navigationTitle("Profile Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                firstName = appState.firstName
                lastName = appState.lastName
                imageData = appState.profileImageData
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func save() {
        appState.updateProfile(firstName: firstName, lastName: lastName, imageData: imageData)
        dismiss()
    }
}
