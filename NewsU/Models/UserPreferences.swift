import Foundation

struct UserPreferences: Codable, Equatable {
    var selectedTopicIDs: Set<String> = ["world", "faith", "technology"]
    var notificationsEnabled: Bool = true
    var notificationHour: Int = 7
    var notificationMinute: Int = 0
    var hasCompletedOnboarding: Bool = false
    var displayName: String = ""

    var selectedTopics: [Topic] {
        Topic.all.filter { selectedTopicIDs.contains($0.id) }
    }
}
