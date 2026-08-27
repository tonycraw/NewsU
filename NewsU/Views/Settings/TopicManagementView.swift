import SwiftUI

struct TopicManagementView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            NewsUTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Tap to add or remove a topic from your daily brief.")
                        .font(.newsUBody)
                        .foregroundStyle(NewsUTheme.inkSecondary)
                        .padding(.top, 12)

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
                }
                .padding(20)
            }
        }
        .navigationTitle("My Topics")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { TopicManagementView() }
        .environmentObject(AppState())
}
