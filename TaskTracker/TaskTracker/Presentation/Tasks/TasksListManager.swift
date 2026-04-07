import UIKit

protocol TasksListManagerDelegate: AnyObject {
    func didSelectTask(id: TaskID)
}

final class TasksListManager: NSObject {
    weak var delegate: TasksListManagerDelegate?

    private var items: [TaskItemVM] = []

    func attach(to tableView: UITableView) {
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
    }

    func setItems(_ items: [TaskItemVM], in tableView: UITableView) {
        self.items = items
        tableView.reloadData()
    }
}

extension TasksListManager: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.reuseIdentifier, for: indexPath)

        guard let taskCell = cell as? TaskTableViewCell else {
            return cell
        }

        taskCell.configure(with: item)
        return taskCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelectTask(id: item.id)
    }
}

final class TaskTableViewCell: UITableViewCell {
    static let reuseIdentifier = "TaskTableViewCell"

    private let rightLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupRightLabel()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentConfiguration = nil
        accessoryType = .none
        accessoryView = nil
        rightLabel.text = nil
    }

    func configure(with item: TaskItemVM) {
        var configuration = defaultContentConfiguration()
        configuration.text = item.title
        configuration.secondaryText = secondaryText(for: item)
        configuration.secondaryTextProperties.numberOfLines = 0
        contentConfiguration = configuration

        rightLabel.text = priorityText(for: item.priority)
        rightLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        rightLabel.textColor = .secondaryLabel
        rightLabel.sizeToFit()
        accessoryView = rightLabel
        accessoryType = .disclosureIndicator
    }

    private func setupRightLabel() {
        rightLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        rightLabel.setContentHuggingPriority(.required, for: .horizontal)
    }

    private func secondaryText(for item: TaskItemVM) -> String {
        let status = statusText(for: item.status)
        if let deadlineText = item.deadlineText {
            return "\(status) • Срок: \(deadlineText)"
        }
        return status
    }

    private func statusText(for status: TaskStatus) -> String {
        switch status {
        case .planned:
            return "Запланирована"
        case .inProgress:
            return "В работе"
        case .completed:
            return "Завершена"
        case .cancelled:
            return "Отменена"
        }
    }

    private func priorityText(for priority: TaskPriority) -> String {
        switch priority {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        case .critical:
            return "Critical"
        }
    }
}
