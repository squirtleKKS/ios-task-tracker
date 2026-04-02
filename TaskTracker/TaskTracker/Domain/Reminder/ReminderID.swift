import Foundation

struct ReminderID: Equatable, Hashable {
    let rawValue: String
    init(_ rawValue: String) { self.rawValue = rawValue }
}
