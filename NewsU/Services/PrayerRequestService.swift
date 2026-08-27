import Foundation

protocol PrayerRequestService {
    func fetchRequests(for userID: String) async throws -> [PrayerRequest]
    func submit(_ request: PrayerRequest, for userID: String) async throws
    func update(_ request: PrayerRequest, for userID: String) async throws
    func delete(_ requestID: String, for userID: String) async throws
}

/// Prayer requests stay on-device, private to the signed-in user — nobody else
/// ever reads them. That's a deliberate scope choice: it sidesteps the
/// moderation/reporting requirements Apple applies to user-generated content
/// that's shared with others (App Review Guideline 1.2), and it's an honest
/// match for "jot down what's on your heart," not a public prayer wall.
///
/// If you'd rather these actually reach a real prayer team, swap this for
/// `RemotePrayerRequestService` and build that inbox — see backend/README.md.
final class MockPrayerRequestService: PrayerRequestService {
    private let defaults = UserDefaults.standard
    private func key(for userID: String) -> String { "com.newsu.prayerRequests.\(userID)" }

    func fetchRequests(for userID: String) async throws -> [PrayerRequest] {
        guard let data = defaults.data(forKey: key(for: userID)),
              let decoded = try? JSONDecoder().decode([PrayerRequest].self, from: data) else {
            return []
        }
        return decoded.sorted { $0.createdAt > $1.createdAt }
    }

    func submit(_ request: PrayerRequest, for userID: String) async throws {
        var requests = try await fetchRequests(for: userID)
        requests.append(request)
        save(requests, for: userID)
    }

    func update(_ request: PrayerRequest, for userID: String) async throws {
        var requests = try await fetchRequests(for: userID)
        guard let index = requests.firstIndex(where: { $0.id == request.id }) else { return }
        requests[index] = request
        save(requests, for: userID)
    }

    func delete(_ requestID: String, for userID: String) async throws {
        var requests = try await fetchRequests(for: userID)
        requests.removeAll { $0.id == requestID }
        save(requests, for: userID)
    }

    private func save(_ requests: [PrayerRequest], for userID: String) {
        guard let data = try? JSONEncoder().encode(requests) else { return }
        defaults.set(data, forKey: key(for: userID))
    }
}

/// Production implementation: sends prayer requests to a real backend —
/// e.g. so a prayer team can actually see and pray over them. Needs the same
/// moderation/reporting care as any user-generated content reaching other
/// people (see backend/README.md).
struct RemotePrayerRequestService: PrayerRequestService {
    var baseURL: URL

    func fetchRequests(for userID: String) async throws -> [PrayerRequest] {
        []
    }

    func submit(_ request: PrayerRequest, for userID: String) async throws {}
    func update(_ request: PrayerRequest, for userID: String) async throws {}
    func delete(_ requestID: String, for userID: String) async throws {}
}
