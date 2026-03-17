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
        view.backgroundColor = .systemBackground
        title = screenTitle

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = screenTitle
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}
