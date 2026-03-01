import Foundation

enum ReminderSchedule: Equatable, Codable {
    case once(at: Date)
    case daily(hour: Int, minute: Int)
    case weekly(weekday: Weekday, hour: Int, minute: Int)
}
