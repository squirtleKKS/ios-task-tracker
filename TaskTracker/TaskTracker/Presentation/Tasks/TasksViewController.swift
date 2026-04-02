import UIKit

final class TasksViewController: UIViewController {

    var viewModel: TasksViewModel!

    private let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Tasks"

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 14)

        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])

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
        switch state.screen {
        case .initial:
            textView.text = "initial"

        case .loading:
            textView.text = "loading..."

        case .content(let items):
            let lines = items.prefix(20).map {
                "\($0.title) | \($0.status) | \($0.priority) | \($0.deadlineText ?? "no deadline")"
            }
            textView.text = """
            loaded: \(items.count)

            \(lines.joined(separator: "\n"))
            """

        case .empty(let message):
            textView.text = "empty: \(message)"

        case .error(let message):
            textView.text = "error: \(message)"
        }
    }
}
