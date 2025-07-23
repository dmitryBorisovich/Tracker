import UIKit
import CoreData

final class TrackerStore {
    
    enum TrackerError: Error {
        case trackerNotFound
    }
    
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
    
    private func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        context.performAndWait { result = action(context) }
        return try result.get()
    }
    
    func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
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
    
    func convertToTracker(_ trackerCoreData: TrackerCoreData) -> Tracker {
        var schedule: [DaysOfWeek]?
        if let coreDataSchedule = trackerCoreData.schedule {
            schedule = scheduleMarshalling.schedule(from: coreDataSchedule)
        }
        
        return Tracker(
            id: trackerCoreData.id ?? UUID(),
            name: trackerCoreData.name ?? "",
            color: colorMarshalling.color(from: trackerCoreData.color ?? ""),
            emoji: trackerCoreData.emoji ?? "",
            schedule: schedule
        )
    }
    
    func addNewTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
        try performSync { context in
            Result {
                let trackerCoreData = TrackerCoreData(context: context)
                updateExistingTracker(trackerCoreData, with: tracker)
                
                let categoryFetchRequest = TrackerCategoryCoreData.fetchRequest()
                categoryFetchRequest.predicate = NSPredicate(format: "name == %@", category.name)
                
                if let existingCategory = try context.fetch(categoryFetchRequest).first {
                    trackerCoreData.category = existingCategory
                } else {
                    let newCategory = TrackerCategoryCoreData(context: context)
                    newCategory.name = category.name
                    trackerCoreData.category = newCategory
                }
                
                try context.save()
            }
        }
    }
    
    func deleteTracker(tracker: TrackerCoreData) throws {
        try performSync { context in
            Result {
                context.delete(tracker)
                try context.save()
            }
        }
    }
}
