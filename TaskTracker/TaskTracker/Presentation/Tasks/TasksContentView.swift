import UIKit

final class TasksContentView: UIView {

    let tableView = UITableView(frame: .zero, style: .plain)
    let loadingView = DSLoadingView(text: "Загружаем задачи...")
    let messageView = DSMessageView(style: .empty, title: "", message: "", actionTitle: "Повторить")
    let refreshControl = UIRefreshControl()
    let searchController = UISearchController(searchResultsController: nil)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupTableView()
        setupSearch()
    }

    required init?(coder: NSCoder) {
        fatalError()
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

    func setRefreshing(_ isRefreshing: Bool) {
        if isRefreshing {
            if !refreshControl.isRefreshing {
                refreshControl.beginRefreshing()
            }
        } else {
            refreshControl.endRefreshing()
        }
    }
}

private extension TasksContentView {
    func setupUI() {
        backgroundColor = DesignSystem.Colors.background

        [tableView, loadingView, messageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        messageView.isHidden = true
        loadingView.isHidden = true
    }

    func setupLayout() {
        addSubview(tableView)
        addSubview(loadingView)
        addSubview(messageView)

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
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.keyboardDismissMode = .onDrag
        tableView.refreshControl = refreshControl
    }

    func setupSearch() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск по задачам"
        searchController.searchBar.searchTextField.backgroundColor = DesignSystem.Colors.surface
        searchController.searchBar.searchTextField.textColor = DesignSystem.Colors.textPrimary
        searchController.searchBar.searchTextField.tintColor = DesignSystem.Colors.primary
        searchController.searchBar.searchTextField.layer.cornerRadius = 18
        searchController.searchBar.searchTextField.layer.masksToBounds = true
        searchController.searchBar.searchTextField.layer.borderWidth = 1
        searchController.searchBar.searchTextField.layer.borderColor = DesignSystem.Colors.border.cgColor
    }
}
