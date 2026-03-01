import Foundation

protocol StatisticsRepository {
    func loadTasksStats(period: StatsPeriod) async throws -> TasksStats
}
