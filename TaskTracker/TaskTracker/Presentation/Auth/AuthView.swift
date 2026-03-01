import Foundation

protocol AuthView: AnyObject {
    func render(_ state: AuthViewState)
}
