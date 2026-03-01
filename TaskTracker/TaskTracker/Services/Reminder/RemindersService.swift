import Foundation

protocol RemindersService {
    func getReminders(taskId: TaskID?) async throws -> [TaskReminder]

    func createReminder(taskId: TaskID, schedule: ReminderSchedule) async throws -> TaskReminder

    func setEnabled(reminderId: ReminderID, isEnabled: Bool) async throws -> TaskReminder

    func deleteReminder(reminderId: ReminderID) async throws
}
