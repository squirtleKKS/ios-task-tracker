import UIKit

final class TasksViewController: UIViewController {

    var viewModel: TasksViewModel!

    private lazy var tableView = UITableView(frame: .zero, style: .plain)
    private lazy var loadingView = DSLoadingView(text: "Загружаем задачи...")
    private lazy var messageView = DSMessageView(style: .empty, title: "", message: "", actionTitle: "Повторить")
    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)
    private let listManager = TasksListManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupTableView()
        setupSearch()
        setupActions()
        bindViewModel()
        render(viewModel.state)
        viewModel.onAppear()
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
            loadingView.stopAnimating()
            loadingView.isHidden = true
            messageView.isHidden = true
            tableView.isHidden = true

        case .loading:
            if state.isRefreshing {
                messageView.isHidden = true
                tableView.isHidden = false
            } else {
                loadingView.isHidden = false
                loadingView.startAnimating()
                messageView.isHidden = true
                tableView.isHidden = true
            }

        case .content(let items):
            loadingView.stopAnimating()
            loadingView.isHidden = true
            messageView.isHidden = true
            tableView.isHidden = false
            listManager.setItems(items, in: tableView)

        case .empty(let message):
            loadingView.stopAnimating()
            loadingView.isHidden = true
            tableView.isHidden = true
            messageView.isHidden = false
            messageView.configure(title: "Пусто", message: message, actionTitle: nil)
            listManager.setItems([], in: tableView)

        case .error(let message):
            loadingView.stopAnimating()
            loadingView.isHidden = true
            if state.isRefreshing {
                messageView.isHidden = true
                tableView.isHidden = false
            } else {
                tableView.isHidden = true
                messageView.isHidden = false
                messageView.configure(title: "Ошибка", message: message, actionTitle: "Повторить")
            }
            listManager.setItems([], in: tableView)
        }
    }
}

private extension TasksViewController {
    func setupUI() {
        title = "Задачи"
        view.backgroundColor = DesignSystem.Colors.background

        [tableView, loadingView, messageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag

        loadingView.isHidden = true
        messageView.isHidden = true

        view.addSubview(tableView)
        view.addSubview(loadingView)
        view.addSubview(messageView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            messageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DesignSystem.Spacing.l),
            messageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DesignSystem.Spacing.l)
        ])
    }

    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: DesignSystem.Colors.textPrimary,
            .font: DesignSystem.Typography.largeTitle()
        ]
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: DesignSystem.Colors.textPrimary,
            .font: DesignSystem.Typography.heading()
        ]
        navigationController?.navigationBar.tintColor = DesignSystem.Colors.textPrimary

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Error",
            style: .plain,
            target: self,
            action: #selector(didTapSimulateError)
        )
        navigationItem.rightBarButtonItem?.tintColor = DesignSystem.Colors.primary
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
        searchController.searchBar.searchTextField.backgroundColor = DesignSystem.Colors.surface
        searchController.searchBar.searchTextField.textColor = DesignSystem.Colors.textPrimary
        searchController.searchBar.searchTextField.tintColor = DesignSystem.Colors.primary
        searchController.searchBar.searchTextField.layer.cornerRadius = 18
        searchController.searchBar.searchTextField.layer.masksToBounds = true
        searchController.searchBar.searchTextField.layer.borderWidth = 1
        searchController.searchBar.searchTextField.layer.borderColor = DesignSystem.Colors.border.cgColor
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    func setupActions() {
        refreshControl.tintColor = DesignSystem.Colors.primary
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        messageView.actionButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
    }

    @objc func didPullToRefresh() {
        viewModel.didPullToRefresh()
    }

    @objc func didTapRetry() {
        viewModel.didTapRetry()
    }

    @objc func didTapSimulateError() {
        viewModel.didTapSimulateError()
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
