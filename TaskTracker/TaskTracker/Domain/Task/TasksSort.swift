import Foundation

enum TasksSort: Equatable {
    case createdAt(order: SortOrder)
    case deadline(order: SortOrder)
    case priority(order: SortOrder)
    case status(order: SortOrder)
}

enum SortOrder: String, Equatable {
    case ascending
    case descending
}
