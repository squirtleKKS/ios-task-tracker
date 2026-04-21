import Foundation

struct BackendDrivenScreenConfiguration {
    let title: String?
    let endpoint: URL

    init(
        title: String? = nil,
        endpoint: URL
    ) {
        self.title = title
        self.endpoint = endpoint
    }
}
