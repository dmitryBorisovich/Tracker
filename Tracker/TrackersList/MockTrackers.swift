import UIKit

final class MockTrackers {
    static let shared = MockTrackers()
    
    private init() {}
    
    var categories: [TrackerCategory] = [
        TrackerCategory(
            name: "Спорт",
            trackers: [
                Tracker(id: UUID(),
                        name: "Пробежать 3 км",
                        color: .blue,
                        emoji: "👟",
                        schedule: [DaysOfWeek.monday, DaysOfWeek.thursday]),
                Tracker(id: UUID(),
                        name: "Поднять гирю 20 раз",
                        color: .brown,
                        emoji: "💪🏻",
                        schedule: [DaysOfWeek.tuesday, DaysOfWeek.friday])
            ]
        ),
        TrackerCategory(
            name: "Чтение",
            trackers: [
                Tracker(id: UUID(),
                        name: "Прочесть 10 страниц",
                        color: .tGreen,
                        emoji: "📕",
                        schedule: [DaysOfWeek.monday, DaysOfWeek.wednesday, DaysOfWeek.saturday])
            ]
        )
    ]
}

