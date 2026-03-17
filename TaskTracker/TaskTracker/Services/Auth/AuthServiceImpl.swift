import Foundation

enum AuthError: LocalizedError {
    case invalidCredentials

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Неверный email или пароль"
        }
    }
}

final class AuthServiceImpl: AuthService {

    private let validEmail = "admin"
    private let validPassword = "admin"

    func login(email: String, password: String) async throws -> UserSession {
        try await simulateDelay()

        guard email == validEmail, password == validPassword else {
            throw AuthError.invalidCredentials
        }

        return makeSession()
    }

    func register(email: String, password: String) async throws -> UserSession {
        try await simulateDelay()

        return makeSession()
    }

    func logout() async {
    }
}

private extension AuthServiceImpl {
    func makeSession() -> UserSession {
        UserSession(
            accessToken: UUID().uuidString,
            refreshToken: nil,
            userId: UserID("123"),
            expiresAt: Date().addingTimeInterval(3600)
        )
    }

    func simulateDelay() async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }
}
