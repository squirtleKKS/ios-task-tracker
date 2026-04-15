import UIKit

final class TasksContentView: UIView {

    var onTaskSelected: ((TaskID) -> Void)?
    var onRetryTap: (() -> Void)?
    var onRefresh: (() -> Void)?
    var onSearchQueryChanged: ((String) -> Void)?

    let searchController = UISearchController(searchResultsController: nil)

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let loadingView = DSLoadingView(text: "Загружаем задачи...")
    private let messageView = DSMessageView(style: .empty, title: "", message: "", actionTitle: "Повторить")
    private let refreshControl = UIRefreshControl()
    private let listManager = TasksListManager()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupTableView()
        setupSearch()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func render(_ state: TasksViewState) {
        renderSearchQuery(state.searchQuery)
        renderRefreshing(state.isRefreshing)
        renderScreen(state.screen, isRefreshing: state.isRefreshing)
    }
}

private extension TasksContentView {
    func setupUI() {
        backgroundColor = DesignSystem.Colors.background

        [tableView, loadingView, messageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.keyboardDismissMode = .onDrag

        loadingView.isHidden = true
        messageView.isHidden = true

        addSubview(tableView)
        addSubview(loadingView)
        addSubview(messageView)
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            loadingView.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: centerYAnchor),

            messageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            messageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DesignSystem.Spacing.l),
            messageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DesignSystem.Spacing.l)
        ])
    }

    func setupTableView() {
        listManager.attach(to: tableView)
        listManager.onTaskSelected = { [weak self] taskID in
            self?.onTaskSelected?(taskID)
        }

        tableView.refreshControl = refreshControl
    }

    func setupSearch() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Поиск по задачам"
        searchController.searchBar.searchTextField.backgroundColor = DesignSystem.Colors.surface
        searchController.searchBar.searchTextField.textColor = DesignSystem.Colors.textPrimary
        searchController.searchBar.searchTextField.tintColor = DesignSystem.Colors.primary
        searchController.searchBar.searchTextField.layer.cornerRadius = 18
        searchController.searchBar.searchTextField.layer.masksToBounds = true
        searchController.searchBar.searchTextField.layer.borderWidth = 1
        searchController.searchBar.searchTextField.layer.borderColor = DesignSystem.Colors.border.cgColor
    }

    func setupActions() {
        refreshControl.tintColor = DesignSystem.Colors.primary
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        messageView.actionButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
    }

    func renderSearchQuery(_ query: String) {
        if searchController.searchBar.text != query {
            searchController.searchBar.text = query
        }
    }

    func renderRefreshing(_ isRefreshing: Bool) {
        if isRefreshing {
            if !refreshControl.isRefreshing {
                refreshControl.beginRefreshing()
            }
        } else {
            refreshControl.endRefreshing()
        }
    }

    func renderScreen(_ screen: LoadableState<[TaskItemVM]>, isRefreshing: Bool) {
        switch screen {
        case .initial:
            listManager.setItems([], in: tableView)
            showInitial()

        case .loading:
            if isRefreshing {
                messageView.isHidden = true
                tableView.isHidden = false
            } else {
                listManager.setItems([], in: tableView)
                showLoading()
            }

        case .content(let items):
            listManager.setItems(items, in: tableView)
            showContent()

        case .empty(let message):
            listManager.setItems([], in: tableView)
            showMessage(title: "Пусто", message: message, actionTitle: nil)

        case .error(let message):
            if isRefreshing {
                messageView.isHidden = true
                tableView.isHidden = false
            } else {
                listManager.setItems([], in: tableView)
                showMessage(title: "Ошибка", message: message, actionTitle: "Повторить")
            }
            loadingView.stopAnimating()
            loadingView.isHidden = true
        }
    }

    func showInitial() {
        loadingView.stopAnimating()
        loadingView.isHidden = true
        messageView.isHidden = true
        tableView.isHidden = true
    }

    func showLoading() {
        loadingView.isHidden = false
        loadingView.startAnimating()
        messageView.isHidden = true
        tableView.isHidden = true
    }

    func showContent() {
        loadingView.stopAnimating()
        loadingView.isHidden = true
        messageView.isHidden = true
        tableView.isHidden = false
    }

    func showMessage(title: String, message: String, actionTitle: String?) {
        loadingView.stopAnimating()
        loadingView.isHidden = true
        tableView.isHidden = true
        messageView.isHidden = false
        messageView.configure(title: title, message: message, actionTitle: actionTitle)
    }

    @objc func didPullToRefresh() {
        onRefresh?()
    }

    @objc func didTapRetry() {
        onRetryTap?()
    }
}

extension TasksContentView: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        onSearchQueryChanged?(searchController.searchBar.text ?? "")
    }
}
