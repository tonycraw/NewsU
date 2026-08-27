import Foundation

enum BriefServiceError: Error {
    case noResource
    case decodingFailed
    case server(String)
}

protocol BriefService {
    /// Returns today's AI-curated brief, already filtered/ordered for the given topics.
    func fetchTodaysBrief(for topics: [Topic]) async throws -> NewsBrief
}

/// Loads the bundled sample brief. This stands in for the real backend so the app
/// is fully demoable offline. Swap `AppState.briefService` for `RemoteBriefService`
/// once the curation backend (see /backend in the project root) is deployed.
struct MockBriefService: BriefService {
    func fetchTodaysBrief(for topics: [Topic]) async throws -> NewsBrief {
        guard let url = Bundle.main.url(forResource: "sample_brief", withExtension: "json") else {
            throw BriefServiceError.noResource
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        var brief = try decoder.decode(NewsBrief.self, from: data)

        // Re-date it to "today" so the demo always feels current, and restrict
        // sections to the topics the user actually subscribed to.
        let topicIDs = Set(topics.map(\.id))
        let filteredSections = brief.sections.filter { topicIDs.contains($0.topicId) }
        brief = NewsBrief(
            date: Date(),
            greeting: brief.greeting,
            openingPrayer: brief.openingPrayer,
            sections: filteredSections.isEmpty ? brief.sections : filteredSections,
            closingBlessing: brief.closingBlessing
        )
        return brief
    }
}

/// Production implementation: fetches the day's already-curated brief from a
/// single static JSON file — no server needed. The scheduled GitHub Actions
/// workflow (`.github/workflows/daily-curation.yml`) runs `backend/curate.js`
/// once a day and commits its output to `public/brief-latest.json`; this just
/// does a plain GET on that file's raw URL (e.g.
/// `https://raw.githubusercontent.com/<you>/<repo>/main/public/brief-latest.json`)
/// and filters it down to each user's topics client-side, the same way
/// `MockBriefService` does. All AI work happens ahead of time, offline from
/// the app, so the app itself stays a thin, hands-off reader.
struct RemoteBriefService: BriefService {
    var briefURL: URL

    func fetchTodaysBrief(for topics: [Topic]) async throws -> NewsBrief {
        let (data, response) = try await URLSession.shared.data(from: briefURL)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw BriefServiceError.server("Unexpected response")
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let brief: NewsBrief
        do {
            brief = try decoder.decode(NewsBrief.self, from: data)
        } catch {
            throw BriefServiceError.decodingFailed
        }

        let topicIDs = Set(topics.map(\.id))
        let filteredSections = brief.sections.filter { topicIDs.contains($0.topicId) }
        return NewsBrief(
            date: brief.date,
            greeting: brief.greeting,
            openingPrayer: brief.openingPrayer,
            sections: filteredSections.isEmpty ? brief.sections : filteredSections,
            closingBlessing: brief.closingBlessing
        )
    }
}
