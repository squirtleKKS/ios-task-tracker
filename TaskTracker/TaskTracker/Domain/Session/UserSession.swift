import Foundation

struct UserSession: Equatable {
    let accessToken: String
    let refreshToken: String?
    let userId: UserID
    let expiresAt: Date?
}
