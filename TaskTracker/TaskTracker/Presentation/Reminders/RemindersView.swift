import Foundation

protocol RemindersView: AnyObject {
    func render(_ state: RemindersViewState)
}
