import UIKit

final class FeaturesViewController: UIViewController {

    var viewModel: FeaturesViewModel!

    private var items: [FeatureItemVM] = []
    private lazy var contentView = FeaturesContentView()

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Фичи"

        setupNavigationBar()
        setupTableView()
        bindViewModel()
        render(viewModel.state)

        viewModel.onAppear()
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
    }

    private func render(_ state: FeaturesViewState) {
        switch state.screen {
        case .initial:
            contentView.loadingView.stopAnimating()
            contentView.loadingView.isHidden = true
            contentView.messageView.isHidden = true
            contentView.tableView.isHidden = true

        case .loading:
            contentView.loadingView.isHidden = false
            contentView.loadingView.startAnimating()
            contentView.messageView.isHidden = true
            contentView.tableView.isHidden = true

        case .content(let items):
            self.items = items
            contentView.loadingView.stopAnimating()
            contentView.loadingView.isHidden = true
            contentView.messageView.isHidden = true
            contentView.tableView.isHidden = false
            contentView.tableView.reloadData()

        case .empty(let message):
            self.items = []
            contentView.tableView.reloadData()
            contentView.loadingView.stopAnimating()
            contentView.loadingView.isHidden = true
            contentView.tableView.isHidden = true
            contentView.messageView.isHidden = false
            contentView.messageView.configure(title: "Пусто", message: message, actionTitle: nil)

        case .error(let message):
            self.items = []
            contentView.tableView.reloadData()
            contentView.loadingView.stopAnimating()
            contentView.loadingView.isHidden = true
            contentView.tableView.isHidden = true
            contentView.messageView.isHidden = false
            contentView.messageView.configure(title: "Ошибка", message: message, actionTitle: nil)
        }
    }
}

private extension FeaturesViewController {

    func setupNavigationBar() {
        view.backgroundColor = DesignSystem.Colors.background

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: DesignSystem.Colors.textPrimary,
            .font: DesignSystem.Typography.largeTitle()
        ]
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: DesignSystem.Colors.textPrimary,
            .font: DesignSystem.Typography.heading()
        ]

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(didTapLogout)
        )
        navigationItem.rightBarButtonItem?.tintColor = DesignSystem.Colors.primary
    }

    func setupTableView() {
        contentView.tableView.register(FeatureCell.self, forCellReuseIdentifier: FeatureCell.reuseIdentifier)
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        contentView.tableView.rowHeight = UITableView.automaticDimension
        contentView.tableView.estimatedRowHeight = 110
    }

    @objc func didTapLogout() {
        viewModel.didTapLogout()
    }
}

extension FeaturesViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let item = items[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: FeatureCell.reuseIdentifier, for: indexPath)

        guard let cell = cell as? FeatureCell else { return cell }
        cell.configure(with: item)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.section]
        tableView.deselectRow(at: indexPath, animated: true)

        guard item.isEnabled else { return }
        viewModel.didSelectFeature(id: item.id)
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

        titleLabel.font = DesignSystem.Typography.heading()
        subtitleLabel.font = DesignSystem.Typography.body()
        subtitleLabel.numberOfLines = 0

        statusLabel.font = DesignSystem.Typography.captionMedium()
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 12
        statusLabel.layer.masksToBounds = true

        chevronView.contentMode = .scaleAspectFit

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

            chevronView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -DesignSystem.Spacing.l),
            chevronView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: DesignSystem.Sizes.iconSmall),
            chevronView.heightAnchor.constraint(equalToConstant: DesignSystem.Sizes.iconSmall),

            statusLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -DesignSystem.Spacing.s),
            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 64),
            statusLabel.heightAnchor.constraint(equalToConstant: 24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DesignSystem.Spacing.xs),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: DesignSystem.Spacing.l),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -DesignSystem.Spacing.l),
            subtitleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -DesignSystem.Spacing.l)
        ])
    }
}
