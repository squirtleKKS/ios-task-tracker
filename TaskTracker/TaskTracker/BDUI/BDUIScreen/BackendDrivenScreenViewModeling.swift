import UIKit

protocol BackendDrivenScreenViewModeling: AnyObject {
    var onLoadingChange: ((Bool) -> Void)? { get set }
    var onViewLoaded: ((UIView) -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }

    func onAppear()
}


final class BackendDrivenScreenViewModel: BackendDrivenScreenViewModeling {

    var onLoadingChange: ((Bool) -> Void)?
    var onViewLoaded: ((UIView) -> Void)?
    var onError: ((Error) -> Void)?

    private let configuration: BackendDrivenScreenConfiguration
    private let loader: BackendDrivenScreenLoading
    private let mapper: BDUIViewMapping

    init(
        configuration: BackendDrivenScreenConfiguration,
        loader: BackendDrivenScreenLoading,
        mapper: BDUIViewMapping
    ) {
        self.configuration = configuration
        self.loader = loader
        self.mapper = mapper
    }

    func onAppear() {
        loadScreen()
    }
}

private extension BackendDrivenScreenViewModel {
    func loadScreen() {
        onLoadingChange?(true)

        Task { [weak self] in
            guard let self else { return }

            do {
                let screen = try await loader.loadScreen(configuration: configuration)
                let view = mapper.map(node: screen.root)

                onLoadingChange?(false)
                onViewLoaded?(view)
            } catch {
                onLoadingChange?(false)
                onError?(error)
            }
        }
    }
}
