import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home, quiz, spin, prep, profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .quiz: return "Quiz"
        case .spin: return "Spin"
        case .prep: return "Prep"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .quiz: return "brain.head.profile"
        case .spin: return "circle.circle"
        case .prep: return "checklist"
        case .profile: return "person.fill"
        }
    }
}

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tabItem { Label(AppTab.home.title, systemImage: AppTab.home.icon) }
                .tag(AppTab.home)

            QuizView()
                .tabItem { Label(AppTab.quiz.title, systemImage: AppTab.quiz.icon) }
                .tag(AppTab.quiz)

            SimulatorView()
                .tabItem { Label(AppTab.spin.title, systemImage: AppTab.spin.icon) }
                .tag(AppTab.spin)

            PrepView()
                .tabItem { Label(AppTab.prep.title, systemImage: AppTab.prep.icon) }
                .tag(AppTab.prep)

            ProfileView()
                .tabItem { Label(AppTab.profile.title, systemImage: AppTab.profile.icon) }
                .tag(AppTab.profile)
        }
        .tint(AppColors.teal)
    }
}
