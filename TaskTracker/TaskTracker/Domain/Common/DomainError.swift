import Foundation

enum DomainError: Error, Equatable {
    case validation(message: String)
    case unauthorized
    case notFound
    case network
    case unknown
}
