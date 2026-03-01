import Foundation

protocol StatisticsService {
    func getTasksStats(period: StatsPeriod) async throws -> TasksStats
}
