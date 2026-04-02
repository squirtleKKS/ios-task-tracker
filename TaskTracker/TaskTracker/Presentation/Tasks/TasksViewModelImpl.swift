import Foundation

@MainActor
final class TasksViewModelImpl: TasksViewModel {

    var onStateChange: ((TasksViewState) -> Void)?

    private let service: TasksService
    private let router: TasksRouter
    private let deadlineFormatter: DateFormatter

    private var loadTask: Task<Void, Never>?

    private(set) var state = TasksViewState(
        screen: .initial,
        isRefreshing: false,
        filter: TasksFilter(),
        sort: nil
    ) {
        didSet { onStateChange?(state) }
    }

    init(
        service: TasksService,
        router: TasksRouter
    ) {
        self.service = service
        self.router = router

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        self.deadlineFormatter = formatter
    }

    func onAppear() {
        guard case .initial = state.screen else { return }
        load(isRefreshing: false)
    }

    func didPullToRefresh() {
        load(isRefreshing: true)
    }

    func didTapCreate(
        title: String,
        description: String?,
        priority: TaskPriority,
        deadline: Date?
    ) {
        Task { [weak self] in
            guard let self else { return }

            do {
                _ = try await service.createTask(
                    title: title,
                    description: description,
                    priority: priority,
                    deadline: deadline
                )
                load(isRefreshing: false)
            } catch {
                setError(error)
            }
        }
    }

    func didTapDelete(taskId: TaskID) {
        Task { [weak self] in
            guard let self else { return }

            do {
                try await service.deleteTask(id: taskId)
                load(isRefreshing: false)
            } catch {
                setError(error)
            }
        }
    }

    func didChangeFilter(_ filter: TasksFilter) {
        updateState { $0.filter = filter }
        load(isRefreshing: false)
    }

    func didChangeSort(_ sort: TasksSort?) {
        updateState { $0.sort = sort }
        load(isRefreshing: false)
    }

    func didSelectTask(taskId: TaskID) {
        router.openTaskDetails(taskId: taskId)
    }

    private func load(isRefreshing: Bool) {
        loadTask?.cancel()

        let filter = state.filter
        let sort = state.sort

        updateState {
            if isRefreshing {
                $0.isRefreshing = true
            } else {
                $0.screen = .loading
                $0.isRefreshing = false
            }
        }

        loadTask = Task { [weak self] in
            guard let self else { return }

            do {
                let tasks = try await service.getTasks(
                    filter: filter,
                    sort: sort
                )

                guard !Task.isCancelled else { return }

                let items = tasks.map(mapToItemVM)

                updateState {
                    $0.isRefreshing = false
                    $0.screen = items.isEmpty
                        ? .empty(message: "Нет задач")
                        : .content(items)
                }
            } catch {
                guard !Task.isCancelled else { return }
                setError(error)
            }
        }
    }

    private func mapToItemVM(_ task: TaskModel) -> TaskItemVM {
        TaskItemVM(
            id: task.id,
            title: task.title,
            status: task.status,
            priority: task.priority,
            deadlineText: formatDeadline(task.deadline)
        )
    }

    private func formatDeadline(_ date: Date?) -> String? {
        guard let date else { return nil }
        return deadlineFormatter.string(from: date)
    }

    private func setError(_ error: Error) {
        updateState {
            $0.isRefreshing = false
            $0.screen = .error(message: mapError(error))
        }
    }

    private func mapError(_ error: Error) -> String {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .invalidResponse:
                return "Некорректный ответ сервера"
            case .statusCode(let code):
                return "Ошибка сервера: \(code)"
            case .decoding:
                return "Не удалось обработать данные"
            case .transport:
                return "Ошибка сети"
            case .cancelled:
                return "Запрос отменён"
            }
        }

        return "Что-то пошло не так"
    }

    private func updateState(_ mutate: (inout TasksViewState) -> Void) {
        var newState = state
        mutate(&newState)
        state = newState
    }
}
