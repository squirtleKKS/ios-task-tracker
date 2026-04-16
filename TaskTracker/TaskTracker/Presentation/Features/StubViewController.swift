import UIKit

final class StubViewController: UIViewController {
    private let screenTitle: String

    init(screenTitle: String) {
        self.screenTitle = screenTitle
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignSystem.Colors.background
        title = screenTitle

        let cardView = UIView()
        let label = UILabel()

        cardView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false

        cardView.applyCardStyle()

        label.text = screenTitle
        label.apply(.title)
        label.textAlignment = .center
        label.numberOfLines = 0

        view.addSubview(cardView)
        cardView.addSubview(label)

        NSLayoutConstraint.activate([
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DesignSystem.Spacing.xl),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DesignSystem.Spacing.xl),

            label.topAnchor.constraint(equalTo: cardView.topAnchor, constant: DesignSystem.Spacing.xl),
            label.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: DesignSystem.Spacing.l),
            label.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -DesignSystem.Spacing.l),
            label.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -DesignSystem.Spacing.xl)
        ])
    }
}
