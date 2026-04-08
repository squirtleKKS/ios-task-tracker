import UIKit

final class DSLoadingView: UIView {

    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let titleLabel = UILabel()
    private let stackView = UIStackView()

    init(text: String = "Загрузка...") {
        super.init(frame: .zero)
        setup(text: text)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func startAnimating() {
        isHidden = false
        activityIndicator.startAnimating()
    }

    func stopAnimating() {
        activityIndicator.stopAnimating()
        isHidden = true
    }

    private func setup(text: String) {
        translatesAutoresizingMaskIntoConstraints = false

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = DesignSystem.Colors.primary

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.apply(.bodySecondary)
        titleLabel.text = text
        titleLabel.textAlignment = .center

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = DesignSystem.Spacing.s
        stackView.alignment = .center

        addSubview(stackView)
        stackView.addArrangedSubview(activityIndicator)
        stackView.addArrangedSubview(titleLabel)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: DesignSystem.Spacing.l),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DesignSystem.Spacing.xl),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DesignSystem.Spacing.xl),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -DesignSystem.Spacing.l)
        ])

        backgroundColor = DesignSystem.Colors.surface.withAlphaComponent(0.96)
        layer.cornerRadius = DesignSystem.CornerRadius.m
        layer.borderWidth = 1
        layer.borderColor = DesignSystem.Colors.border.cgColor
        layer.shadowColor = DesignSystem.Colors.shadow.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }
}
