import UIKit

final class FeaturesViewController: UIViewController {

    var viewModel: FeaturesViewModel!

    private var items: [FeatureItemVM] = []
    private let contentView = FeaturesContentView()

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Фичи"

        setupNavigationBar()
        setupTableView()
        bindViewModel()
        render(viewModel.state)

        viewModel.onAppear()
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
    }

    private func render(_ state: FeaturesViewState) {
        switch state.screen {
        case .initial:
            contentView.activityIndicator.stopAnimating()
            contentView.tableView.isHidden = true
            contentView.messageLabel.isHidden = true

        case .loading:
            contentView.activityIndicator.startAnimating()
            contentView.tableView.isHidden = true
            contentView.messageLabel.isHidden = true

        case .content(let items):
            self.items = items
            contentView.activityIndicator.stopAnimating()
            contentView.messageLabel.isHidden = true
            contentView.tableView.isHidden = false
            contentView.tableView.reloadData()

        case .empty(let message):
            contentView.activityIndicator.stopAnimating()
            contentView.tableView.isHidden = true
            contentView.messageLabel.isHidden = false
            contentView.messageLabel.text = message

        case .error(let message):
            contentView.activityIndicator.stopAnimating()
            contentView.tableView.isHidden = true
            contentView.messageLabel.isHidden = false
            contentView.messageLabel.text = message
        }
    }
}

private extension FeaturesViewController {

    func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(didTapLogout)
        )
    }

    func setupTableView() {
        contentView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FeatureCell")
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
    }

    @objc func didTapLogout() {
        viewModel.didTapLogout()
    }
}

extension FeaturesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeatureCell", for: indexPath)

        var config = cell.defaultContentConfiguration()
        config.text = item.title
        config.secondaryText = item.subtitle

        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = item.isEnabled ? .default : .none
        cell.isUserInteractionEnabled = item.isEnabled
        cell.contentView.alpha = item.isEnabled ? 1.0 : 0.5

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)

        guard item.isEnabled else { return }
        viewModel.didSelectFeature(id: item.id)
    }
}
