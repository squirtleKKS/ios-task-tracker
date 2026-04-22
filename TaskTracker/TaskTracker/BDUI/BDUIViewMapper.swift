import UIKit

final class BDUIViewMapper: BDUIViewMapping {

    private weak var actionHandler: BDUIActionHandling?

    init(actionHandler: BDUIActionHandling) {
        self.actionHandler = actionHandler
    }

    func map(node: BDUINode) -> UIView {
        let view = makeView(for: node)
        applyBaseLayout(node.layout, to: view)
        attachSubviews(node.subviews, to: view, layout: node.layout)
        return view
    }
}

private extension BDUIViewMapper {
    func makeView(for node: BDUINode) -> UIView {
        switch node.props {
        case .container(let props):
            return makeContainer(props: props)

        case .stack(let props):
            return makeStack(props: props)

        case .label(let props):
            return makeLabel(props: props)

        case .button(let props):
            return makeButton(props: props)

        case .textField(let props):
            return makeTextField(props: props)

        case .message(let props):
            return makeMessage(props: props)

        case .loading(let props):
            return makeLoading(props: props)
        }
    }

    func makeContainer(props: BDUIContainerProps) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        if props.cardStyle == true {
            view.applyCardStyle()
        }

        return view
    }

    func makeStack(props: BDUIStackProps) -> UIStackView {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = props.axis.value
        view.spacing = props.spacing.value
        view.alignment = props.alignment?.value ?? .fill
        view.distribution = props.distribution?.value ?? .fill
        return view
    }

    func makeLabel(props: BDUILabelProps) -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = props.text
        view.apply(props.style.value)
        view.textAlignment = props.textAlignment?.value ?? .natural
        view.numberOfLines = props.numberOfLines ?? 0
        return view
    }

    func makeButton(props: BDUIButtonProps) -> DSButton {
        DSButton(
            configuration: DSButtonConfiguration(
                title: props.title,
                style: props.style.value,
                isEnabled: true,
                isHidden: false,
                accessibilityIdentifier: nil,
                onTap: props.action.map { action in
                    { [weak actionHandler] in
                        actionHandler?.handle(action: action)
                    }
                }
            )
        )
    }

    func makeTextField(props: BDUITextFieldProps) -> DSTextField {
        let view = DSTextField(
            configuration: DSTextFieldConfiguration(
                title: props.title,
                placeholder: props.placeholder,
                text: props.text,
                errorMessage: nil,
                isSecureEntry: props.isSecure ?? false,
                keyboardType: .default,
                returnKeyType: .default,
                autocapitalizationType: .sentences,
                autocorrectionType: .default,
                accessibilityIdentifier: nil
            )
        )
        return view
    }

    func makeMessage(props: BDUIMessageProps) -> DSMessageView {
        DSMessageView(
            configuration: DSMessageViewConfiguration(
                style: props.style.value,
                title: props.title,
                message: props.message,
                actionTitle: props.actionTitle,
                isHidden: false,
                onActionTap: props.action.map { action in
                    { [weak actionHandler] in
                        actionHandler?.handle(action: action)
                    }
                }
            )
        )
    }

    func makeLoading(props: BDUILoadingProps) -> DSLoadingView {
        DSLoadingView(
            configuration: DSLoadingViewConfiguration(
                text: props.text,
                isHidden: false,
                isAnimating: props.isAnimating ?? true
            )
        )
    }
    func applyBaseLayout(_ layout: BDUILayout?, to view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false

        if let color = layout?.backgroundColor?.value {
            view.backgroundColor = color
        }

        if let width = layout?.width {
            view.widthAnchor.constraint(equalToConstant: width).isActive = true
        }

        if let height = layout?.height {
            view.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }

    func attachSubviews(_ subviews: [BDUINode], to parent: UIView, layout: BDUILayout?) {
        guard !subviews.isEmpty else { return }

        if let stack = parent as? UIStackView {
            subviews
                .map(map(node:))
                .forEach { stack.addArrangedSubview($0) }
            return
        }

        let contentContainer = UIView()
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(contentContainer)

        let insets = layout?.padding
        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: parent.topAnchor, constant: insets?.top?.value ?? 0),
            contentContainer.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: insets?.left?.value ?? 0),
            contentContainer.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -(insets?.right?.value ?? 0)),
            contentContainer.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -(insets?.bottom?.value ?? 0))
        ])

        if subviews.count == 1 {
            let child = map(node: subviews[0])
            contentContainer.addSubview(child)

            child.setContentHuggingPriority(.required, for: .vertical)
            child.setContentCompressionResistancePriority(.required, for: .vertical)

            NSLayoutConstraint.activate([
                child.topAnchor.constraint(equalTo: contentContainer.topAnchor),
                child.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
                child.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
                child.bottomAnchor.constraint(lessThanOrEqualTo: contentContainer.bottomAnchor)
            ])
            return
        }

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        contentContainer.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])

        subviews
            .map(map(node:))
            .forEach { stack.addArrangedSubview($0) }
    }
}
