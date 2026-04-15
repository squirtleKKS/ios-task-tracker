import UIKit

final class AuthViewController: UIViewController {

    var viewModel: AuthViewModel!

    private lazy var contentView = AuthContentView()

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bindView()
        bindViewModel()
        setupKeyboardObservers()
        setupTapGesture()

        contentView.render(viewModel.state)
        viewModel.onAppear()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

private extension AuthViewController {
    func bindView() {
        contentView.onEmailChanged = { [weak self] email in
            self?.viewModel.didChangeEmail(email)
        }

        contentView.onPasswordChanged = { [weak self] password in
            self?.viewModel.didChangePassword(password)
        }

        contentView.onPrimaryTap = { [weak self] in
            self?.handlePrimaryTap()
        }

        contentView.onSwitchModeTap = { [weak self] in
            self?.viewModel.didTapSwitchMode()
        }
    }

    func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.contentView.render(state)
        }
    }

    func handlePrimaryTap() {
        switch viewModel.state.mode {
        case .login:
            viewModel.didTapLogin()
        case .register:
            viewModel.didTapRegister()
        }
    }

    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func handleTapOutside() {
        view.endEditing(true)
    }

    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        let keyboardFrameInView = view.convert(endFrame, from: nil)
        let intersection = view.bounds.intersection(keyboardFrameInView)
        contentView.updateKeyboardInset(intersection.height)
    }
}
