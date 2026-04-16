import UIKit

final class TasksContentView: UIView {

    var onTaskSelected: ((TaskID) -> Void)?
    var onRetryTap: (() -> Void)?
    var onRefresh: (() -> Void)?
    var onSearchQueryChanged: ((String) -> Void)?

    let searchController = UISearchController(searchResultsController: nil)

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let loadingView = DSLoadingView()
    private let messageView = DSMessageView()
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
            tableView.isHidden = true
            loadingView.configure(
                DSLoadingViewConfiguration(
                    text: "Загружаем задачи...",
                    isHidden: true,
                    isAnimating: false
                )
            )
            messageView.configure(DSMessageViewConfiguration(isHidden: true))

        case .loading:
            if isRefreshing {
                tableView.isHidden = false
                loadingView.configure(
                    DSLoadingViewConfiguration(
                        text: "Загружаем задачи...",
                        isHidden: true,
                        isAnimating: false
                    )
                )
                messageView.configure(DSMessageViewConfiguration(isHidden: true))
            } else {
                listManager.setItems([], in: tableView)
                tableView.isHidden = true
                loadingView.configure(
                    DSLoadingViewConfiguration(
                        text: "Загружаем задачи...",
                        isHidden: false,
                        isAnimating: true
                    )
                )
                messageView.configure(DSMessageViewConfiguration(isHidden: true))
            }

        case .content(let items):
            listManager.setItems(items, in: tableView)
            tableView.isHidden = false
            loadingView.configure(
                DSLoadingViewConfiguration(
                    text: "Загружаем задачи...",
                    isHidden: true,
                    isAnimating: false
                )
            )
            messageView.configure(DSMessageViewConfiguration(isHidden: true))

        case .empty(let message):
            listManager.setItems([], in: tableView)
            tableView.isHidden = true
            loadingView.configure(
                DSLoadingViewConfiguration(
                    text: "Загружаем задачи...",
                    isHidden: true,
                    isAnimating: false
                )
            )
            messageView.configure(
                DSMessageViewConfiguration(
                    style: .empty,
                    title: "Пусто",
                    message: message,
                    actionTitle: nil,
                    isHidden: false
                )
            )

        case .error(let message):
            if isRefreshing {
                tableView.isHidden = false
                loadingView.configure(
                    DSLoadingViewConfiguration(
                        text: "Загружаем задачи...",
                        isHidden: true,
                        isAnimating: false
                    )
                )
                messageView.configure(DSMessageViewConfiguration(isHidden: true))
            } else {
                listManager.setItems([], in: tableView)
                tableView.isHidden = true
                loadingView.configure(
                    DSLoadingViewConfiguration(
                        text: "Загружаем задачи...",
                        isHidden: true,
                        isAnimating: false
                    )
                )
                messageView.configure(
                    DSMessageViewConfiguration(
                        style: .error,
                        title: "Ошибка",
                        message: message,
                        actionTitle: "Повторить",
                        isHidden: false
                    )
                )
            }
        }
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
