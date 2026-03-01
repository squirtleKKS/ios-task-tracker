import Foundation

struct RemindersViewState: Equatable {
    var screen: LoadableState<[ReminderItemVM]>
    var isRefreshing: Bool
    var scopedTaskId: TaskID?
}

struct ReminderItemVM: Equatable {
    let id: ReminderID
    let taskId: TaskID
    let scheduleText: String
    let isEnabled: Bool
}
