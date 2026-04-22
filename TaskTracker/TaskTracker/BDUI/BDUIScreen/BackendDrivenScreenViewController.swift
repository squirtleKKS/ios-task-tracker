import UIKit

final class BackendDrivenScreenViewController: UIViewController {

    private let viewModel: BackendDrivenScreenViewModeling
    private var renderedView: UIView?

    private let loadingView = DSLoadingView(
        configuration: DSLoadingViewConfiguration(
            text: "Загружаем экран...",
            isHidden: false,
            isAnimating: true
        )
    )

    init(viewModel: BackendDrivenScreenViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupLoadingView()
        viewModel.onAppear()
    }
}

private extension BackendDrivenScreenViewController {
    func bindViewModel() {
        viewModel.onLoadingChange = { [weak self] isLoading in
            guard let self else { return }

            if isLoading {
                showLoading()
            } else {
                hideLoading()
            }
        }

        viewModel.onViewLoaded = { [weak self] view in
            self?.render(view)
        }

        viewModel.onError = { error in
            print(error)
        }
    }

    func setupLoadingView() {
        loadingView.translatesAutoresizingMaskIntoConstraints = false
    }

    func showLoading() {
        guard loadingView.superview == nil else { return }

        view.addSubview(loadingView)

        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func hideLoading() {
        loadingView.removeFromSuperview()
    }

    func render(_ rootView: UIView) {
        renderedView?.removeFromSuperview()
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
