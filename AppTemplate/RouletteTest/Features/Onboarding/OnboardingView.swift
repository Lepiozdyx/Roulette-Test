import SwiftUI

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let subtitle: String
}

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var page = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "img1",
            title: "Learn Before You Play",
            subtitle: "Understand roulette mathematics before entering a real game."
        ),
        OnboardingPage(
            image: "img2",
            title: "Practice Without Risk",
            subtitle: "Train with a virtual balance and improve your strategy safely."
        ),
        OnboardingPage(
            image: "img3",
            title: "Play With Discipline",
            subtitle: "Build healthy habits using planning tools, quizzes and session checklists."
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 8)

            Image(pages[page].image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.horizontal, 20)

            Spacer()

            VStack(spacing: 12) {
                Text(pages[page].title)
                    .font(AppTypography.serifTitle(30))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(pages[page].subtitle)
                    .font(.body)
                    .foregroundStyle(AppColors.muted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                PageIndicator(count: pages.count, current: page)
                    .padding(.top, 8)

                PrimaryButton(title: page == pages.count - 1 ? "Let's Begin" : "Next") {
                    if page < pages.count - 1 {
                        page += 1
                    } else {
                        appState.completeOnboarding()
                    }
                }
                .padding(.top, 12)

                if page < pages.count - 1 {
                    SecondaryTextButton(title: "Skip") {
                        appState.completeOnboarding()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .screenBackground()
    }
}
