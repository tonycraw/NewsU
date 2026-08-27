import SwiftUI

/// A subscribable news category. The catalog is static on-device; the AI curation
/// backend uses `id` to know which stories to gather for a given user.
struct Topic: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let sfSymbol: String
    let colorHex: String

    var color: Color { Color(hex: colorHex) }

    static let all: [Topic] = [
        Topic(id: "world", name: "World", sfSymbol: "globe.americas.fill", colorHex: "3B5B92"),
        Topic(id: "us", name: "U.S. News", sfSymbol: "flag.fill", colorHex: "8B3A3A"),
        Topic(id: "politics", name: "Politics", sfSymbol: "building.columns.fill", colorHex: "6B5B95"),
        Topic(id: "business", name: "Business & Economy", sfSymbol: "chart.line.uptrend.xyaxis", colorHex: "2E7D5B"),
        Topic(id: "technology", name: "Technology", sfSymbol: "cpu.fill", colorHex: "3E6D8E"),
        Topic(id: "health", name: "Health", sfSymbol: "heart.text.square.fill", colorHex: "B5654F"),
        Topic(id: "science", name: "Science", sfSymbol: "atom", colorHex: "4A7A6B"),
        Topic(id: "faith", name: "Faith & Culture", sfSymbol: "book.closed.fill", colorHex: "AD8A3F"),
        Topic(id: "sports", name: "Sports", sfSymbol: "figure.run", colorHex: "5B7A3A"),
        Topic(id: "entertainment", name: "Entertainment", sfSymbol: "film.fill", colorHex: "8E4A7A"),
        Topic(id: "local", name: "Local", sfSymbol: "mappin.and.ellipse", colorHex: "6B6B6B")
    ]

    static func find(_ id: String) -> Topic? {
        all.first { $0.id == id }
    }
}
