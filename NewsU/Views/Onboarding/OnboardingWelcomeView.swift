import SwiftUI

struct OnboardingWelcomeView: View {
    @State private var goToTopics = false

    var body: some View {
        NavigationStack {
            ZStack {
                NewsUTheme.background.ignoresSafeArea()

                VStack(spacing: 28) {
                    Spacer()

                    AppMarkBadge(size: 132)
                        .shadow(color: NewsUTheme.cardShadow, radius: 20, y: 10)

                    VStack(spacing: 10) {
                        Text("NewsU")
                            .font(.newsUWordmark(44))
                            .tracking(0.5)
                            .foregroundStyle(NewsUTheme.ink)
                        Text("Peace before the noise.")
                            .font(.newsUBody)
                            .foregroundStyle(NewsUTheme.inkSecondary)
                    }

                    VStack(alignment: .leading, spacing: 18) {
                        FeatureRow(icon: "hands.sparkles.fill", text: "A calming prayer to open every morning")
                        FeatureRow(icon: "sparkles", text: "News curated by AI around what you care about")
                        FeatureRow(icon: "book.closed.fill", text: "A fitting Bible verse after every story")
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .newsUCard()
                    .padding(.horizontal, 24)

                    Spacer()
                    Spacer()

                    VStack(spacing: 14) {
                        PrimaryButton(title: "Get Started") { goToTopics = true }
                        Text("Free to use · Takes about a minute")
                            .font(.newsUCaption)
                            .foregroundStyle(NewsUTheme.inkFaint)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
            .navigationDestination(isPresented: $goToTopics) {
                TopicSelectionView()
            }
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(NewsUTheme.gold)
                .frame(width: 28)
            Text(text)
                .font(.newsUBody)
                .foregroundStyle(NewsUTheme.ink)
        }
    }
}

#Preview {
    OnboardingWelcomeView()
        .environmentObject(AppState())
}
