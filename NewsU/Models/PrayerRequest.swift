import SwiftUI

enum PrayerCategory: String, Codable, CaseIterable, Identifiable {
    case health, family, guidance, gratitude, other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .health: return "Health"
        case .family: return "Family"
        case .guidance: return "Guidance"
        case .gratitude: return "Gratitude"
        case .other: return "Other"
        }
    }

    var sfSymbol: String {
        switch self {
        case .health: return "heart.text.square.fill"
        case .family: return "house.fill"
        case .guidance: return "map.fill"
        case .gratitude: return "hands.sparkles.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

struct PrayerRequest: Codable, Equatable, Identifiable {
    let id: String
    var text: String
    var category: PrayerCategory
    let createdAt: Date
    var isAnswered: Bool

    init(id: String = UUID().uuidString, text: String, category: PrayerCategory, createdAt: Date = Date(), isAnswered: Bool = false) {
        self.id = id
        self.text = text
        self.category = category
        self.createdAt = createdAt
        self.isAnswered = isAnswered
    }
}
