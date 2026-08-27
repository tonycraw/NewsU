import Foundation

/// Thin Codable-backed UserDefaults store for on-device preferences.
/// Nothing here is sensitive, so plain UserDefaults is appropriate — no Keychain needed.
final class PersistenceService {
    static let shared = PersistenceService()
    private let defaults = UserDefaults.standard
    private let preferencesKey = "com.newsu.userPreferences"
    private let currentUserKey = "com.newsu.currentUser"

    private init() {}

    func loadPreferences() -> UserPreferences {
        guard let data = defaults.data(forKey: preferencesKey),
              let decoded = try? JSONDecoder().decode(UserPreferences.self, from: data) else {
            return UserPreferences()
        }
        return decoded
    }

    func save(_ preferences: UserPreferences) {
        guard let data = try? JSONEncoder().encode(preferences) else { return }
        defaults.set(data, forKey: preferencesKey)
    }

    func loadCurrentUser() -> UserAccount? {
        guard let data = defaults.data(forKey: currentUserKey),
              let decoded = try? JSONDecoder().decode(UserAccount.self, from: data) else {
            return nil
        }
        return decoded
    }

    func saveCurrentUser(_ user: UserAccount?) {
        guard let user else {
            defaults.removeObject(forKey: currentUserKey)
            return
        }
        guard let data = try? JSONEncoder().encode(user) else { return }
        defaults.set(data, forKey: currentUserKey)
    }
}
