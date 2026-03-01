import Foundation

struct TaskReminder: Equatable, Codable {
    let id: ReminderID
    let taskId: TaskID

    let schedule: ReminderSchedule
    let isEnabled: Bool

    let createdAt: Date
    let updatedAt: Date?
}
