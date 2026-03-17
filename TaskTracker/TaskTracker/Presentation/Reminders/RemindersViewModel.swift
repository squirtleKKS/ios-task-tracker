import Foundation

protocol RemindersViewModel: AnyObject {
    func onAppear()
    func didPullToRefresh()
    func didTapCreate(taskId: TaskID, schedule: ReminderSchedule)
    func didToggleEnabled(reminderId: ReminderID, isEnabled: Bool)
    func didTapDelete(reminderId: ReminderID)
}
