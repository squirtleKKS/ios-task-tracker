import Foundation

enum ReminderSchedule: Equatable {
    case once(at: Date)
    case daily(hour: Int, minute: Int)
    case weekly(weekday: Weekday, hour: Int, minute: Int)
}
