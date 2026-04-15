import UIKit
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
