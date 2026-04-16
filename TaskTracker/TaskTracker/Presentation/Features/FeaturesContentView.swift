import UIKit

final class FeaturesContentView: UIView {

    var onFeatureSelected: ((FeatureItemVM) -> Void)?

    private var items: [FeatureItemVM] = []

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let loadingView = DSLoadingView()
    private let messageView = DSMessageView()

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
            tableView.isHidden = true
            loadingView.configure(
                DSLoadingViewConfiguration(
                    text: "Загружаем разделы...",
                    isHidden: true,
                    isAnimating: false
                )
            )
            messageView.configure(DSMessageViewConfiguration(isHidden: true))

        case .loading:
            items = []
            tableView.reloadData()
            tableView.isHidden = true
            loadingView.configure(
                DSLoadingViewConfiguration(
                    text: "Загружаем разделы...",
                    isHidden: false,
                    isAnimating: true
                )
            )
            messageView.configure(DSMessageViewConfiguration(isHidden: true))

        case .content(let items):
            self.items = items
            tableView.reloadData()
            tableView.isHidden = false
            loadingView.configure(
                DSLoadingViewConfiguration(
                    text: "Загружаем разделы...",
                    isHidden: true,
                    isAnimating: false
                )
            )
            messageView.configure(DSMessageViewConfiguration(isHidden: true))

        case .empty(let message):
            items = []
            tableView.reloadData()
            tableView.isHidden = true
            loadingView.configure(
                DSLoadingViewConfiguration(
                    text: "Загружаем разделы...",
                    isHidden: true,
                    isAnimating: false
                )
            )
            messageView.configure(
                DSMessageViewConfiguration(
                    style: .empty,
                    title: "Пусто",
                    message: message,
                    actionTitle: nil,
                    isHidden: false
                )
            )

        case .error(let message):
            items = []
            tableView.reloadData()
            tableView.isHidden = true
            loadingView.configure(
                DSLoadingViewConfiguration(
                    text: "Загружаем разделы...",
                    isHidden: true,
                    isAnimating: false
                )
            )
            messageView.configure(
                DSMessageViewConfiguration(
                    style: .error,
                    title: "Ошибка",
                    message: message,
                    actionTitle: nil,
                    isHidden: false
                )
            )
        }
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
