import Foundation

final class FeaturesViewModelImpl: FeaturesViewModel {
    private weak var view: FeaturesView?
    private let router: FeaturesRouter
    private let authService: AuthService

    private var state = FeaturesViewState(screen: .initial)

    init(
        view: FeaturesView,
        router: FeaturesRouter,
        authService: AuthService
    ) {
        self.view = view
        self.router = router
        self.authService = authService
    }

    func onAppear() {
        state.screen = .content(makeItems())
        render()
    }

    func didSelectFeature(id: FeatureID) {
        switch id.rawValue {
        case AppFeatureKind.tasks.rawValue:
            router.openTasks()
        case AppFeatureKind.statistics.rawValue:
            router.openStatistics()
        case AppFeatureKind.reminders.rawValue:
            router.openReminders()
        default:
            break
        }
    }

    func didTapLogout() {
        Task { [weak self] in
            guard let self else { return }

            await self.authService.logout()

            await MainActor.run {
                self.router.openAuth()
            }
        }
    }

    private func makeItems() -> [FeatureItemVM] {
        [
            FeatureItemVM(
                id: FeatureID(AppFeatureKind.tasks.rawValue),
                title: "Задачи",
                subtitle: "Список задач",
                isEnabled: true,
                kind: .tasks
            ),
            FeatureItemVM(
                id: FeatureID(AppFeatureKind.statistics.rawValue),
                title: "Статистика",
                subtitle: "Прогресс и показатели",
                isEnabled: true,
                kind: .statistics
            ),
            FeatureItemVM(
                id: FeatureID(AppFeatureKind.reminders.rawValue),
                title: "Напоминания",
                subtitle: "Управление уведомлениями",
                isEnabled: true,
                kind: .reminders
            )
        ]
    }

    private func render() {
        view?.render(state)
    }
}
