import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var preferences: UserPreferences {
        didSet { PersistenceService.shared.save(preferences) }
    }
    @Published var brief: NewsBrief?
    @Published var isLoadingBrief = false
    @Published var loadError: String?
    @Published var currentUser: UserAccount? {
        didSet { PersistenceService.shared.saveCurrentUser(currentUser) }
    }
    @Published var prayerRequests: [PrayerRequest] = []
    @Published var isLoadingPrayerRequests = false

    /// Uses the real, live-updating brief once `RemoteConfig.briefURL` is set
    /// (see that file); falls back to the bundled sample data until then, so
    /// the app is always demoable out of the box.
    var briefService: BriefService = RemoteConfig.briefURL.map { RemoteBriefService(briefURL: $0) } ?? MockBriefService()
    var authService: AuthService = MockAuthService()
    var prayerRequestService: PrayerRequestService = MockPrayerRequestService()

    /// App-owner test accounts that skip the subscription check entirely, so
    /// whoever's building this doesn't have to buy their own subscription to
    /// test the app. `#if DEBUG` means this list is compiled out of Release/
    /// App Store archive builds automatically — it can never ship live.
    #if DEBUG
    private static let ownerEmails: Set<String> = [
        "info@elizabethalexandria.co"
    ]
    #endif

    var hasOwnerAccess: Bool {
        #if DEBUG
        guard let email = currentUser?.email.lowercased() else { return false }
        return Self.ownerEmails.contains(email)
        #else
        return false
        #endif
    }

    init() {
        self.preferences = PersistenceService.shared.loadPreferences()
        self.currentUser = PersistenceService.shared.loadCurrentUser()
    }

    // MARK: Auth

    func signUp(email: String, password: String, displayName: String) async throws {
        currentUser = try await authService.signUp(email: email, password: password, displayName: displayName)
    }

    func signIn(email: String, password: String) async throws {
        currentUser = try await authService.signIn(email: email, password: password)
    }

    func signOut() {
        authService.signOut()
        currentUser = nil
    }

    func deleteAccount() async throws {
        guard let user = currentUser else { return }
        try await authService.deleteAccount(email: user.email)
        for request in prayerRequests {
            try? await prayerRequestService.delete(request.id, for: user.id)
        }
        prayerRequests = []
        preferences = UserPreferences()
        currentUser = nil
    }

    func completeOnboarding() {
        preferences.hasCompletedOnboarding = true
        NotificationManager.shared.scheduleDailyReminder(
            hour: preferences.notificationHour,
            minute: preferences.notificationMinute
        )
    }

    func loadTodaysBrief() async {
        isLoadingBrief = true
        loadError = nil
        defer { isLoadingBrief = false }
        do {
            brief = try await briefService.fetchTodaysBrief(for: preferences.selectedTopics)
        } catch {
            loadError = "Couldn't load today's brief. Pull to refresh to try again."
        }
    }

    func updateNotificationTime(hour: Int, minute: Int) {
        preferences.notificationHour = hour
        preferences.notificationMinute = minute
        if preferences.notificationsEnabled {
            NotificationManager.shared.scheduleDailyReminder(hour: hour, minute: minute)
        }
    }

    func setNotificationsEnabled(_ enabled: Bool) {
        preferences.notificationsEnabled = enabled
        if enabled {
            Task {
                let granted = await NotificationManager.shared.requestAuthorization()
                if granted {
                    NotificationManager.shared.scheduleDailyReminder(
                        hour: preferences.notificationHour,
                        minute: preferences.notificationMinute
                    )
                } else {
                    preferences.notificationsEnabled = false
                }
            }
        } else {
            NotificationManager.shared.cancelDailyReminder()
        }
    }

    func toggleTopic(_ topic: Topic) {
        if preferences.selectedTopicIDs.contains(topic.id) {
            preferences.selectedTopicIDs.remove(topic.id)
        } else {
            preferences.selectedTopicIDs.insert(topic.id)
        }
    }

    // MARK: Prayer requests

    func loadPrayerRequests() async {
        guard let userID = currentUser?.id else { return }
        isLoadingPrayerRequests = true
        defer { isLoadingPrayerRequests = false }
        prayerRequests = (try? await prayerRequestService.fetchRequests(for: userID)) ?? []
    }

    func submitPrayerRequest(text: String, category: PrayerCategory) async {
        guard let userID = currentUser?.id else { return }
        let request = PrayerRequest(text: text, category: category)
        try? await prayerRequestService.submit(request, for: userID)
        await loadPrayerRequests()
    }

    func toggleAnswered(_ request: PrayerRequest) async {
        guard let userID = currentUser?.id else { return }
        var updated = request
        updated.isAnswered.toggle()
        try? await prayerRequestService.update(updated, for: userID)
        await loadPrayerRequests()
    }

    func deletePrayerRequest(_ request: PrayerRequest) async {
        guard let userID = currentUser?.id else { return }
        try? await prayerRequestService.delete(request.id, for: userID)
        await loadPrayerRequests()
    }
}
