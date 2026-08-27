import Foundation

struct UserAccount: Codable, Equatable, Identifiable {
    let id: String
    var email: String
    var displayName: String
}
