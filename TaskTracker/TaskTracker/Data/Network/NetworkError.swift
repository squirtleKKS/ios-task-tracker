import Foundation

enum NetworkError: Error, Equatable {
    case invalidResponse
    case statusCode(Int)
    case decoding
    case transport
    case cancelled
}
