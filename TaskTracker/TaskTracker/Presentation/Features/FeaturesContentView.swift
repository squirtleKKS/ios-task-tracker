import UIKit

final class FeaturesContentView: UIView {

    var onFeatureSelected: ((FeatureItemVM) -> Void)?

    private var items: [FeatureItemVM] = []

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let loadingView = DSLoadingView(text: "Загружаем разделы...")
    private let messageView = DSMessageView(style: .empty, title: "", message: "", actionTitle: nil)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupTableView()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func render(_ state: FeaturesViewState) {
        renderScreen(state.screen)
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

    func setupTableView() {
        tableView.register(FeatureCell.self, forCellReuseIdentifier: FeatureCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 110
    }

    func renderScreen(_ screen: LoadableState<[FeatureItemVM]>) {
        switch screen {
        case .initial:
            items = []
            tableView.reloadData()
            showInitial()

        case .loading:
            items = []
            tableView.reloadData()
            showLoading()

        case .content(let items):
            self.items = items
            tableView.reloadData()
            showContent()

        case .empty(let message):
            items = []
            tableView.reloadData()
            showMessage(title: "Пусто", message: message)

        case .error(let message):
            items = []
            tableView.reloadData()
            showMessage(title: "Ошибка", message: message)
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

    func showMessage(title: String, message: String) {
        loadingView.stopAnimating()
        loadingView.isHidden = true
        tableView.isHidden = true
        messageView.configure(title: title, message: message, actionTitle: nil)
        messageView.isHidden = false
    }
}

extension FeaturesContentView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]
        let rawCell = tableView.dequeueReusableCell(withIdentifier: FeatureCell.reuseIdentifier, for: indexPath)

        guard let cell = rawCell as? FeatureCell else {
            return rawCell
        }

        cell.configure(with: item)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.section]
        tableView.deselectRow(at: indexPath, animated: true)

        guard item.isEnabled else { return }
        onFeatureSelected?(item)
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FeatureCell else { return }
        cell.setPressed(true)
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FeatureCell else { return }
        cell.setPressed(false)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        DesignSystem.Spacing.s
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0.01
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
}

private final class FeatureCell: UITableViewCell {
    static let reuseIdentifier = "FeatureCell"

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

    func configure(with item: FeatureItemVM) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle

        if item.isEnabled {
            cardView.backgroundColor = DesignSystem.Colors.primary
            cardView.layer.borderColor = DesignSystem.Colors.primaryPressed.cgColor
            titleLabel.textColor = DesignSystem.Colors.textOnPrimary
            subtitleLabel.textColor = DesignSystem.Colors.textOnPrimary.withAlphaComponent(0.88)
            statusLabel.textColor = DesignSystem.Colors.textOnPrimary
            statusLabel.backgroundColor = UIColor.white.withAlphaComponent(0.18)
            statusLabel.text = "Доступно"
            chevronView.tintColor = DesignSystem.Colors.textOnPrimary
            chevronView.isHidden = false
        } else {
            cardView.backgroundColor = DesignSystem.Colors.surface
            cardView.layer.borderColor = DesignSystem.Colors.border.cgColor
            titleLabel.textColor = DesignSystem.Colors.textPrimary
            subtitleLabel.textColor = DesignSystem.Colors.textSecondary
            statusLabel.textColor = DesignSystem.Colors.textSecondary
            statusLabel.backgroundColor = DesignSystem.Colors.surfaceSecondary
            statusLabel.text = "Скоро"
            chevronView.isHidden = true
        }

        selectionStyle = .none
        isUserInteractionEnabled = item.isEnabled
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

        [cardView, titleLabel, subtitleLabel, statusLabel, chevronView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        cardView.layer.cornerRadius = DesignSystem.CornerRadius.l
        cardView.layer.borderWidth = 1
        cardView.layer.shadowColor = DesignSystem.Colors.shadow.cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)

        titleLabel.apply(.heading)
        titleLabel.numberOfLines = 0

        subtitleLabel.apply(.bodySecondary)
        subtitleLabel.numberOfLines = 0

        statusLabel.apply(.caption)
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = DesignSystem.CornerRadius.pill
        statusLabel.clipsToBounds = true

        chevronView.contentMode = .scaleAspectFit

        contentView.addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
        cardView.addSubview(statusLabel)
        cardView.addSubview(chevronView)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignSystem.Spacing.l),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignSystem.Spacing.l),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -DesignSystem.Spacing.s),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: DesignSystem.Spacing.l),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: DesignSystem.Spacing.l),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronView.leadingAnchor, constant: -DesignSystem.Spacing.m),

            chevronView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            chevronView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -DesignSystem.Spacing.l),
            chevronView.widthAnchor.constraint(equalToConstant: DesignSystem.Sizes.iconSmall),
            chevronView.heightAnchor.constraint(equalToConstant: DesignSystem.Sizes.iconSmall),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DesignSystem.Spacing.s),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: DesignSystem.Spacing.l),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -DesignSystem.Spacing.l),

            statusLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: DesignSystem.Spacing.m),
            statusLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: DesignSystem.Spacing.l),
            statusLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -DesignSystem.Spacing.l),
            statusLabel.heightAnchor.constraint(equalToConstant: 28),
            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 84)
        ])
    }
}
