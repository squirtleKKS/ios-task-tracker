import UIKit

final class TasksViewController: UIViewController {

    var viewModel: TasksViewModel!

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)
    private let listManager = TasksListManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupSearch()
        setupActions()
        bindViewModel()
        render(viewModel.state)
        viewModel.onAppear()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Error",
            style: .plain,
            target: self,
            action: #selector(didTapSimulateError)
        )
    }
    
    @objc func didTapSimulateError() {
        viewModel.didTapSimulateError()
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
    }

    private func render(_ state: TasksViewState) {
        if searchController.searchBar.text != state.searchQuery {
            searchController.searchBar.text = state.searchQuery
        }

        if state.isRefreshing {
            if !refreshControl.isRefreshing {
                refreshControl.beginRefreshing()
            }
        } else {
            refreshControl.endRefreshing()
        }

        switch state.screen {
        case .initial:
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            messageLabel.isHidden = true
            retryButton.isHidden = true

        case .loading:
            activityIndicator.startAnimating()
            tableView.isHidden = true
            messageLabel.isHidden = true
            retryButton.isHidden = true

        case .content(let items):
            activityIndicator.stopAnimating()
            tableView.isHidden = false
            messageLabel.isHidden = true
            retryButton.isHidden = true
            listManager.setItems(items, in: tableView)

        case .empty(let message):
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            messageLabel.isHidden = false
            messageLabel.text = message
            retryButton.isHidden = true
            listManager.setItems([], in: tableView)

        case .error(let message):
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            messageLabel.isHidden = false
            messageLabel.text = message
            retryButton.isHidden = false
            listManager.setItems([], in: tableView)
        }
    }
}

private extension TasksViewController {
    func setupUI() {
        title = "Задачи"
        view.backgroundColor = .systemBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        retryButton.translatesAutoresizingMaskIntoConstraints = false

        tableView.keyboardDismissMode = .onDrag
        activityIndicator.hidesWhenStopped = true

        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.isHidden = true

        retryButton.setTitle("Повторить", for: .normal)
        retryButton.isHidden = true

        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(messageLabel)
        view.addSubview(retryButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -12),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            retryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 12),
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    func setupTableView() {
        listManager.delegate = self
        listManager.attach(to: tableView)
        tableView.refreshControl = refreshControl
    }

    func setupSearch() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск по задачам"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    func setupActions() {
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
    }

    @objc func didPullToRefresh() {
        viewModel.didPullToRefresh()
    }

    @objc func didTapRetry() {
        viewModel.didTapRetry()
    }
}

extension TasksViewController: TasksListManagerDelegate {
    func didSelectTask(id: TaskID) {
        viewModel.didSelectTask(taskId: id)
    }
}

extension TasksViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.didChangeSearchQuery(searchController.searchBar.text ?? "")
    }
}
