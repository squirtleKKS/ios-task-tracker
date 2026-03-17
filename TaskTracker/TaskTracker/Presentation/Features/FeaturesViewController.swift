import UIKit

final class FeaturesViewController: UIViewController, FeaturesView {
    var viewModel: FeaturesViewModel!

    private var items: [FeatureItemVM] = []

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let messageLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupNavigationBar()
        setupTableView()

        viewModel.onAppear()
    }

    func render(_ state: FeaturesViewState) {
        switch state.screen {
        case .initial:
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            messageLabel.isHidden = true

        case .loading:
            activityIndicator.startAnimating()
            tableView.isHidden = true
            messageLabel.isHidden = true

        case .content(let items):
            self.items = items
            activityIndicator.stopAnimating()
            messageLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()

        case .empty(let message):
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            messageLabel.isHidden = false
            messageLabel.text = message

        case .error(let message):
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            messageLabel.isHidden = false
            messageLabel.text = message
        }
    }
}

private extension FeaturesViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Фичи"

        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.isHidden = true

        activityIndicator.hidesWhenStopped = true

        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(messageLabel)
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(didTapLogout)
        )
    }

    func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FeatureCell")
        tableView.dataSource = self
        tableView.delegate = self
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
