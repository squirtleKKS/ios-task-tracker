import Foundation

struct ReminderID: Equatable, Hashable, Codable {
    let rawValue: String
    init(_ rawValue: String) { self.rawValue = rawValue }
}
