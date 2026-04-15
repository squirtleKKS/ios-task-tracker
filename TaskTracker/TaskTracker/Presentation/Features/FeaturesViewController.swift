import UIKit

final class FeaturesViewController: UIViewController {

    var viewModel: FeaturesViewModel!

    private lazy var contentView = FeaturesContentView()

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigation()
        bindView()
        bindViewModel()

        contentView.render(viewModel.state)
        viewModel.onAppear()
    }
}

private extension FeaturesViewController {
    func configureNavigation() {
        title = "Фичи"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(didTapLogout)
        )
        navigationItem.rightBarButtonItem?.tintColor = DesignSystem.Colors.primary
    }

    func bindView() {
        contentView.onFeatureSelected = { [weak self] item in
            self?.viewModel.didSelectFeature(id: item.id)
        }
    }

    func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.contentView.render(state)
        }
    }

    @objc func didTapLogout() {
        viewModel.didTapLogout()
    }
}
