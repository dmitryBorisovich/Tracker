import UIKit
import CoreData

final class TrackerStore {
    
    private let context: NSManagedObjectContext
    
    private let colorMarshalling = UIColorMarshalling()
    private let scheduleMarshalling = ScheduleMarshalling()
    
    convenience init() {
        let context = CoreDataManager.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewTracker(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateExistingTracker(trackerCoreData: trackerCoreData, with: tracker)
        try context.save()
    }
    
    func updateExistingTracker(trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = colorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        
        if let schedule = tracker.schedule {
            trackerCoreData.schedule = scheduleMarshalling.scheduleString(from: schedule)
        } else {
            trackerCoreData.schedule = nil
        }
    }
}
