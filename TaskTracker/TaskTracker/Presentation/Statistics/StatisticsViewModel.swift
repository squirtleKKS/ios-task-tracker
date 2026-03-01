import Foundation

protocol StatisticsViewModel: AnyObject {
    func onAppear()
    func didChangePeriod(_ period: StatsPeriod)
    func didTapRetry()
}
