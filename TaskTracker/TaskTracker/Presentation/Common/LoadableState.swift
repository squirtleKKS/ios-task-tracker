import Foundation

enum LoadableState<Content: Equatable>: Equatable {
    case initial
    case loading
    case content(Content)
    case empty(message: String)
    case error(message: String)
}
