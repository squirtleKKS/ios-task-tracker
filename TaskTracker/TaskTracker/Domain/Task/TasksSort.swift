import Foundation

enum TasksSort: Equatable, Codable {
    case createdAt(order: SortOrder)
    case deadline(order: SortOrder)
    case priority(order: SortOrder)
    case status(order: SortOrder)
}

enum SortOrder: String, Equatable, Codable {
    case ascending
    case descending
}
