import Foundation

final class FeaturesServiceImpl: FeaturesService {

    func getFeatures() async throws -> [AppFeature] {
        return [
            AppFeature(
                id: FeatureID("tasks"),
                kind: .tasks,
                title: "Задачи",
                subtitle: "Управление задачами",
                isEnabled: true
            ),
            AppFeature(
                id: FeatureID("statistics"),
                kind: .statistics,
                title: "Статистика",
                subtitle: "Аналитика задач",
                isEnabled: false
            ),
            AppFeature(
                id: FeatureID("reminders"),
                kind: .reminders,
                title: "Напоминания",
                subtitle: "Уведомления",
                isEnabled: false
            )
        ]
    }
}
