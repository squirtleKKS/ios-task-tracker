import UIKit

final class BDUIProfileViewController: UIViewController {

    private let screenProvider: BDUIScreenProviding
    private lazy var mapper = BDUIViewMapper(actionHandler: self)

    init(screenProvider: BDUIScreenProviding = BDUIProfileJSONProvider()) {
        self.screenProvider = screenProvider
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "BDUI Профиль"
        view.backgroundColor = DesignSystem.Colors.background
        render()
    }
}

private extension BDUIProfileViewController {
    func render() {
        do {
            let screen = try screenProvider.makeScreen()
            let rootView = mapper.map(node: screen.root)

            view.addSubview(rootView)

            NSLayoutConstraint.activate([
                rootView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                rootView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                rootView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                rootView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
            ])
        } catch {
            let fallback = DSMessageView(
                style: .error,
                title: "Ошибка",
                message: "Не удалось декодировать BDUI экран",
                actionTitle: nil
            )
            fallback.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(fallback)

            NSLayoutConstraint.activate([
                fallback.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                fallback.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DesignSystem.Spacing.l),
                fallback.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DesignSystem.Spacing.l)
            ])
        }
    }
}

extension BDUIProfileViewController: BDUIActionHandling {
    func handle(action: BDUIAction) {
        switch action.type {
        case .print:
            print(action.payload?["message"] ?? "BDUI action")

        case .route:
            let destination = action.payload?["destination"]

            if destination == "back" {
                navigationController?.popViewController(animated: true)
            }
        }
    }
}
