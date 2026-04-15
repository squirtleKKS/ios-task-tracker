import UIKit

final class TasksListManager: NSObject {
    var onTaskSelected: ((TaskID) -> Void)?

    private var items: [TaskItemVM] = []

    func attach(to tableView: UITableView) {
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 96
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
    }

    func setItems(_ items: [TaskItemVM], in tableView: UITableView) {
        let oldItems = self.items
        self.items = items

        guard oldItems != items else { return }

        UIView.performWithoutAnimation {
            tableView.reloadData()
        }
    }
}

extension TasksListManager: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let rawCell = tableView.dequeueReusableCell(
            withIdentifier: TaskTableViewCell.reuseIdentifier,
            for: indexPath
        )

        guard let taskCell = rawCell as? TaskTableViewCell else {
            return rawCell
        }

        taskCell.configure(with: item)
        return taskCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        onTaskSelected?(item.id)
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TaskTableViewCell else { return }
        cell.setPressed(true)
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TaskTableViewCell else { return }
        cell.setPressed(false)
    }
}

final class TaskTableViewCell: UITableViewCell {
    static let reuseIdentifier = "TaskTableViewCell"

    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let statusLabel = UILabel()
    private let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
        statusLabel.text = nil
        setPressed(false)
    }

    func configure(with item: TaskItemVM) {
        titleLabel.text = item.title
        subtitleLabel.text = secondaryText(for: item)
        statusLabel.text = priorityText(for: item.priority)
        statusLabel.textColor = badgeTextColor(for: item.priority)
        statusLabel.backgroundColor = badgeBackgroundColor(for: item.priority)
    }

    func setPressed(_ pressed: Bool) {
        UIView.animate(withDuration: 0.14) {
            self.cardView.transform = pressed ? CGAffineTransform(scaleX: 0.985, y: 0.985) : .identity
            self.cardView.alpha = pressed ? 0.92 : 1
        }
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        let selectedBackground = UIView()
        selectedBackground.backgroundColor = .clear
        selectedBackgroundView = selectedBackground

        [cardView, titleLabel, subtitleLabel, statusLabel, chevronView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        cardView.layer.cornerRadius = DesignSystem.CornerRadius.l
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = DesignSystem.Colors.border.cgColor
        cardView.layer.shadowColor = DesignSystem.Colors.shadow.cgColor
        cardView.layer.shadowOpacity = 0
        cardView.layer.shadowRadius = 0
        cardView.layer.shadowOffset = .zero
        cardView.backgroundColor = DesignSystem.Colors.surface

        titleLabel.font = DesignSystem.Typography.heading()
        titleLabel.textColor = DesignSystem.Colors.textPrimary
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        subtitleLabel.font = DesignSystem.Typography.body()
        subtitleLabel.textColor = DesignSystem.Colors.textSecondary
        subtitleLabel.numberOfLines = 0

        statusLabel.font = DesignSystem.Typography.captionMedium()
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 12
        statusLabel.layer.masksToBounds = true
        statusLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        statusLabel.setContentHuggingPriority(.required, for: .horizontal)

        chevronView.tintColor = DesignSystem.Colors.primary
        chevronView.contentMode = .scaleAspectFit
        chevronView.setContentCompressionResistancePriority(.required, for: .horizontal)

        contentView.addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
        cardView.addSubview(statusLabel)
        cardView.addSubview(chevronView)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: DesignSystem.Spacing.s),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignSystem.Spacing.l),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignSystem.Spacing.l),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -DesignSystem.Spacing.s),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: DesignSystem.Spacing.l),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: DesignSystem.Spacing.l),

            chevronView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            chevronView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -DesignSystem.Spacing.l),
            chevronView.widthAnchor.constraint(equalToConstant: DesignSystem.Sizes.iconSmall),
            chevronView.heightAnchor.constraint(equalToConstant: DesignSystem.Sizes.iconSmall),

            statusLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -DesignSystem.Spacing.s),
            statusLabel.heightAnchor.constraint(equalToConstant: 24),
            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 72),

            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusLabel.leadingAnchor, constant: -DesignSystem.Spacing.m),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DesignSystem.Spacing.s),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: DesignSystem.Spacing.l),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -DesignSystem.Spacing.l),
            subtitleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -DesignSystem.Spacing.l)
        ])
    }

    private func secondaryText(for item: TaskItemVM) -> String {
        let status = statusText(for: item.status)
        if let deadlineText = item.deadlineText, !deadlineText.isEmpty {
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

    private func badgeTextColor(for priority: TaskPriority) -> UIColor {
        switch priority {
        case .low:
            return DesignSystem.Colors.textSecondary
        case .medium:
            return DesignSystem.Colors.primary
        case .high:
            return DesignSystem.Colors.primaryPressed
        case .critical:
            return DesignSystem.Colors.error
        }
    }

    private func badgeBackgroundColor(for priority: TaskPriority) -> UIColor {
        DesignSystem.Colors.surfaceSecondary
    }
}
