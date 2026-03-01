import Foundation

enum TaskStatus: String, Equatable, Codable {
    case planned
    case inProgress
    case completed
    case cancelled
}
