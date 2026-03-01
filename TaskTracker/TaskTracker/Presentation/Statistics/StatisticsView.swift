import Foundation

protocol StatisticsView: AnyObject {
    func render(_ state: StatisticsViewState)
}
