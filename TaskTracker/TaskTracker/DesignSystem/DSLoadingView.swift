import UIKit

struct DSLoadingViewConfiguration {
    let text: String?
    let isHidden: Bool
    let isAnimating: Bool

    init(
        text: String? = nil,
        isHidden: Bool = true,
        isAnimating: Bool = false
    ) {
        self.text = text
        self.isHidden = isHidden
        self.isAnimating = isAnimating
    }
}

final class DSLoadingView: UIView {

    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let label = UILabel()

    init(configuration: DSLoadingViewConfiguration = .init()) {
        super.init(frame: .zero)
        setup()
        configure(configuration)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(_ configuration: DSLoadingViewConfiguration) {
        label.text = configuration.text
        isHidden = configuration.isHidden

        if configuration.isAnimating {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false

        [activityIndicator, label].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        label.apply(.bodySecondary)
        label.textAlignment = .center

        let stackView = UIStackView(arrangedSubviews: [activityIndicator, label])
        stackView.axis = .vertical
        stackView.spacing = DesignSystem.Spacing.s
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
