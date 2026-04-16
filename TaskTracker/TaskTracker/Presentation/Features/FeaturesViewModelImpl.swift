import Foundation

@MainActor
final class FeaturesViewModelImpl: FeaturesViewModel {
    var onStateChange: ((FeaturesViewState) -> Void)?

    private let router: FeaturesRouter
    private let authService: AuthService
    private let featuresService: FeaturesService

    private(set) var state = FeaturesViewState(screen: .initial) {
        didSet { onStateChange?(state) }
    }

    init(
        router: FeaturesRouter,
        authService: AuthService,
        featuresService: FeaturesService
    ) {
        self.router = router
        self.authService = authService
        self.featuresService = featuresService
    }

    func onAppear() {
        load()
    }

    func didSelectFeature(id: FeatureID) {
        guard case .content(let items) = state.screen,
              let item = items.first(where: { $0.id == id }) else { return }

        switch item.kind {
        case .tasks:
            router.openTasks()
        case .bdui:
            router.openBDUI()
        case .statistics:
            router.openStatistics()
        case .reminders:
            router.openReminders()
        }
    }

    func didTapLogout() {
        Task { [weak self] in
            guard let self else { return }
            await authService.logout()
            router.openAuth()
        }
    }

    private func load() {
        updateState { $0.screen = .loading }

        Task { [weak self] in
            guard let self else { return }

            do {
                let features = try await featuresService.getFeatures()

                let items = features.map {
                    FeatureItemVM(
                        id: $0.id,
                        title: $0.title,
                        subtitle: $0.subtitle,
                        isEnabled: $0.isEnabled,
                        kind: $0.kind
                    )
                }

                updateState {
                    $0.screen = items.isEmpty
                        ? .empty(message: "Нет доступных фич")
                        : .content(items)
                }
            } catch {
                updateState {
                    $0.screen = .error(message: "Ошибка загрузки")
                }
            }
        }
    }

    private func updateState(_ mutate: (inout FeaturesViewState) -> Void) {
        var newState = state
        mutate(&newState)
        state = newState
    }
}
