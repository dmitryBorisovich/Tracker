import Foundation

// TODO: Сделать единый VC для создания привычки/события
protocol TrackerCreatingDelegate: AnyObject {
    func didCreateNewTracker(in category: TrackerCategory)
}

struct TrackerCategory {
    let name: String
    let trackers: [Tracker]
}
