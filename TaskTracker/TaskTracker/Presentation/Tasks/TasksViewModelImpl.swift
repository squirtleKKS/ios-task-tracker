import Foundation

final class TasksViewModelImpl: TasksViewModel {

    weak var view: TasksView?

    private let service: TasksService
    private let router: TasksRouter

    private var loadTask: Task<Void, Never>?
    private var state: TasksViewState

    init(
        view: TasksView,
        service: TasksService,
        router: TasksRouter
    ) {
        self.view = view
        self.service = service
        self.router = router
        self.state = TasksViewState(
            screen: .initial,
            isRefreshing: false,
            filter: TasksFilter(),
            sort: nil
        )
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
                _ = try await self.service.createTask(
                    title: title,
                    description: description,
                    priority: priority,
                    deadline: deadline
                )
                await MainActor.run {
                    self.load(isRefreshing: false)
                }
            } catch {
                await MainActor.run {
                    self.state.isRefreshing = false
                    self.state.screen = .error(message: self.mapError(error))
                    self.render()
                }
            }
        }
    }

    func didTapDelete(taskId: TaskID) {
        Task { [weak self] in
            guard let self else { return }

            do {
                try await self.service.deleteTask(id: taskId)
                await MainActor.run {
                    self.load(isRefreshing: false)
                }
            } catch {
                await MainActor.run {
                    self.state.isRefreshing = false
                    self.state.screen = .error(message: self.mapError(error))
                    self.render()
                }
            }
        }
    }

    func didChangeFilter(_ filter: TasksFilter) {
        state.filter = filter
        render()
        load(isRefreshing: false)
    }

    func didChangeSort(_ sort: TasksSort?) {
        state.sort = sort
        render()
        load(isRefreshing: false)
    }

    func didSelectTask(taskId: TaskID) {
        router.openTaskDetails(taskId: taskId)
    }

    private func load(isRefreshing: Bool) {
        loadTask?.cancel()

        if isRefreshing {
            state.isRefreshing = true
        } else {
            state.screen = .loading
        }
        render()

        let filter = state.filter
        let sort = state.sort

        loadTask = Task { [weak self] in
            guard let self else { return }

            do {
                let items = try await self.service.getTasks(
                    filter: filter,
                    sort: sort
                )

                if Task.isCancelled { return }

                await MainActor.run {
                    self.state.isRefreshing = false
                    if items.isEmpty {
                        self.state.screen = .empty(message: "Нет задач")
                    } else {
                        self.state.screen = .content(items)
                    }
                    self.render()
                }
            } catch {
                if Task.isCancelled { return }

                await MainActor.run {
                    self.state.isRefreshing = false
                    self.state.screen = .error(message: self.mapError(error))
                    self.render()
                }
            }
        }
    }

    private func render() {
        view?.render(state)
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
}
