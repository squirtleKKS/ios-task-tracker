import Foundation

protocol NetworkClient {
    func get<T: Decodable>(_ url: URL, decoder: JSONDecoder) async throws -> T
}
