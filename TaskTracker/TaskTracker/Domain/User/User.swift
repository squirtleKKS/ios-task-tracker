import Foundation

struct User: Equatable, Codable {
    let id: UserID
    let displayName: String
    let email: String
}
