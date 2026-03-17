import Foundation

struct UserSession: Equatable, Codable {
    let accessToken: String
    let refreshToken: String?
    let userId: UserID
    let expiresAt: Date?
}
