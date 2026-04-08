import UIKit

final class FeaturesContentView: UIView {

    let tableView = UITableView(frame: .zero, style: .plain)
    let loadingView = DSLoadingView(text: "Загружаем разделы...")
    let messageView = DSMessageView(style: .empty, title: "", message: "", actionTitle: nil)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}

private extension FeaturesContentView {
    func setupUI() {
        backgroundColor = DesignSystem.Colors.background

        [tableView, loadingView, messageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false

        loadingView.isHidden = true
        messageView.isHidden = true
        messageView.actionButton.isHidden = true

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
}
