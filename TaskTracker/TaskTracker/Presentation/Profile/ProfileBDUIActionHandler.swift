import UIKit

final class ProfileBDUIActionHandler: BDUIActionHandling {

    var onBack: (() -> Void)?

    func handle(action: BDUIAction) {
        switch action.type {
        case .print:
            print(action.payload?["message"] ?? "BDUI action")

        case .route:
            if action.payload?["destination"] == "back" {
                onBack?()
            }
        }
    }
}
