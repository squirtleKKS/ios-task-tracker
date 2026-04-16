import Foundation

@MainActor
final class TasksViewModelImpl: TasksViewModel {

    var onStateChange: ((TasksViewState) -> Void)?

    private let service: TasksService
    private let router: TasksRouter
    private let deadlineFormatter: DateFormatter

    private var loadTask: Task<Void, Never>?
    private var allTasks: [TaskModel] = []
    private var shouldFailNextLoad = false

    private(set) var state = TasksViewState() {
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

    func didTapRetry() {
        load(isRefreshing: false)
    }

    func didChangeSearchQuery(_ query: String) {
        updateState { $0.searchQuery = query }
        applySearch()
    }

    func didTapSimulateError() {
        shouldFailNextLoad = true
        load(isRefreshing: false)
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

        let currentFilter = state.filter
        let sort = state.sort
        let serviceFilter = TasksFilter(
            statuses: currentFilter.statuses,
            priorities: currentFilter.priorities,
            overdueOnly: currentFilter.overdueOnly,
            searchQuery: nil
        )

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
                if shouldFailNextLoad {
                    shouldFailNextLoad = false
                    try await Task.sleep(nanoseconds: 300_000_000)
                    throw NetworkError.transport
                }

                let tasks = try await service.getTasks(
                    filter: serviceFilter,
                    sort: sort
                )

                guard !Task.isCancelled else { return }

                allTasks = tasks
                applySearch()
            } catch {
                guard !Task.isCancelled else { return }
                setError(error)
            }
        }
    }

    private func applySearch() {
        let query = state.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let filteredTasks: [TaskModel]
        if query.isEmpty {
            filteredTasks = allTasks
        } else {
            filteredTasks = allTasks.filter {
                $0.title.lowercased().contains(query)
                || ($0.description?.lowercased().contains(query) ?? false)
            }
        }

        let items = filteredTasks.map(mapToItemVM)

        updateState {
            $0.isRefreshing = false
            $0.screen = items.isEmpty
                ? .empty(message: query.isEmpty ? "Нет задач" : "Ничего не найдено")
                : .content(items)
        }
    } // искать по доменным моделям, а не viewModel

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
