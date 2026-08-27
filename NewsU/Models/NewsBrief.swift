import Foundation

/// The full daily package produced by the AI curation backend and consumed
/// read-only by the app. One `NewsBrief` = one morning's Today's Brief.
struct NewsBrief: Codable, Equatable {
    let date: Date
    let greeting: String
    let openingPrayer: Prayer
    let sections: [NewsSection]
    let closingBlessing: String
}

struct Prayer: Codable, Equatable {
    let title: String
    let body: String
}

struct NewsSection: Codable, Equatable, Identifiable {
    var id: String { topicId }
    let topicId: String
    let articles: [Article]
    let verse: Verse

    var topic: Topic {
        Topic.find(topicId) ?? Topic(id: topicId, name: topicId.capitalized, sfSymbol: "newspaper.fill", colorHex: "6B6B6B")
    }
}

struct Article: Codable, Equatable, Identifiable {
    let id: String
    let headline: String
    let source: String
    let summary: String
    let url: String
    let publishedAt: Date
    let trustNote: String
}

struct Verse: Codable, Equatable {
    let reference: String
    let text: String
    let reflection: String
}
