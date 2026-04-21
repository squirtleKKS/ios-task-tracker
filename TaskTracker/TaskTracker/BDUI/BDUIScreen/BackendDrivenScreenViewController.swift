import UIKit

final class BackendDrivenScreenViewController: UIViewController {

    var onError: ((Error) -> Void)?

    private let configuration: BackendDrivenScreenConfiguration
    private let loader: BackendDrivenScreenLoading
    private let mapper: BDUIViewMapping
    private let loadingView: UIView
    private let actionHandler: BDUIActionHandling

    private var renderedView: UIView?

    init(
        configuration: BackendDrivenScreenConfiguration,
        loader: BackendDrivenScreenLoading,
        mapper: BDUIViewMapping,
        loadingView: UIView,
        actionHandler: BDUIActionHandling
    ) {
        self.configuration = configuration
        self.loader = loader
        self.mapper = mapper
        self.loadingView = loadingView
        self.actionHandler = actionHandler
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingView()
        loadScreen()
    }
}

private extension BackendDrivenScreenViewController {
    func setupLoadingView() {
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)

        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func loadScreen() {
        Task { [weak self] in
            guard let self else { return }

            do {
                let screen = try await loader.loadScreen(configuration: configuration)
                render(screen)
            } catch {
                onError?(error)
            }
        }
    }

    func render(_ screen: BDUIScreen) {
        loadingView.removeFromSuperview()
        renderedView?.removeFromSuperview()

        let rootView = mapper.map(node: screen.root)
        renderedView = rootView

        view.addSubview(rootView)
        NSLayoutConstraint.activate([
            rootView.topAnchor.constraint(equalTo: view.topAnchor),
            rootView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        ])
    }
}
