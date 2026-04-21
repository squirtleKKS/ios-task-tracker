import Foundation

protocol BackendDrivenScreenLoading {
    func loadScreen(configuration: BackendDrivenScreenConfiguration) async throws -> BDUIScreen
}

final class BackendDrivenScreenLoader: BackendDrivenScreenLoading {

    private let networkClient: NetworkClient
    private let decoder: JSONDecoder

    init(
        networkClient: NetworkClient = URLSessionNetworkClient(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.networkClient = networkClient
        self.decoder = decoder
    }

    func loadScreen(configuration: BackendDrivenScreenConfiguration) async throws -> BDUIScreen {
        try await networkClient.get(configuration.endpoint, decoder: decoder)
    }
}
