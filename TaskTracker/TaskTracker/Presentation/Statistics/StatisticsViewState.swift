import Foundation

struct StatisticsViewState: Equatable {
    var screen: LoadableState<StatisticsContent>
    var period: StatsPeriod
}

struct StatisticsContent: Equatable {
    let stats: TasksStats
}
