import Foundation

protocol SessionStore {
    var currentSession: UserSession? { get }

    func save(_ session: UserSession)
    func clear()
}
