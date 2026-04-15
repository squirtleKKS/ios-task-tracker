import UIKit

final class TasksViewController: UIViewController {

    var viewModel: TasksViewModel!

    private lazy var contentView = TasksContentView()

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigation()
        bindView()
        bindViewModel()
        configureSearch()

        contentView.render(viewModel.state)
        viewModel.onAppear()
    }
}

private extension TasksViewController {
    func configureNavigation() {
        title = "Задачи"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Error",
            style: .plain,
            target: self,
            action: #selector(didTapSimulateError)
        )
        navigationItem.rightBarButtonItem?.tintColor = DesignSystem.Colors.primary
    }

    func configureSearch() {
        navigationItem.searchController = contentView.searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    func bindView() {
        contentView.onTaskSelected = { [weak self] taskID in
            self?.viewModel.didSelectTask(taskId: taskID)
        }

        contentView.onRetryTap = { [weak self] in
            self?.viewModel.didTapRetry()
        }

        contentView.onRefresh = { [weak self] in
            self?.viewModel.didPullToRefresh()
        }

        contentView.onSearchQueryChanged = { [weak self] query in
            self?.viewModel.didChangeSearchQuery(query)
        }
    }

    func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.contentView.render(state)
        }
    }

    @objc func didTapSimulateError() {
        viewModel.didTapSimulateError()
    }
}
