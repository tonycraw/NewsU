import SwiftUI

struct TopicSelectionView: View {
    @EnvironmentObject var appState: AppState
    @State private var goToNotifications = false

    var body: some View {
        ZStack {
            NewsUTheme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What matters to you?")
                        .font(.newsUTitle)
                        .foregroundStyle(NewsUTheme.ink)
                    Text("Choose the topics you'd like your AI-curated brief to focus on. You can change these anytime.")
                        .font(.newsUBody)
                        .foregroundStyle(NewsUTheme.inkSecondary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 20)

                ScrollView {
                    FlowLayout(spacing: 10) {
                        ForEach(Topic.all) { topic in
                            TopicChip(
                                topic: topic,
                                isSelected: appState.preferences.selectedTopicIDs.contains(topic.id)
                            ) {
                                appState.toggleTopic(topic)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }

                VStack(spacing: 10) {
                    PrimaryButton(
                        title: "Continue",
                        isEnabled: !appState.preferences.selectedTopicIDs.isEmpty
                    ) {
                        goToNotifications = true
                    }
                    Text("Pick at least one topic to continue")
                        .font(.newsUCaption)
                        .foregroundStyle(NewsUTheme.inkFaint)
                        .opacity(appState.preferences.selectedTopicIDs.isEmpty ? 1 : 0)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $goToNotifications) {
            NotificationSetupView()
        }
    }
}

#Preview {
    NavigationStack { TopicSelectionView() }
        .environmentObject(AppState())
}
