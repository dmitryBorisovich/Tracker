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
    
    func addNewTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
        // Создаём объект TrackerCoreData
        let trackerCoreData = TrackerCoreData(context: context)
        updateExistingTracker(trackerCoreData, with: tracker)
        
        // Находим или создаём категорию
        let categoryFetchRequest = TrackerCategoryCoreData.fetchRequest()
        categoryFetchRequest.predicate = NSPredicate(format: "name == %@", category.name)
        
        if let existingCategory = try context.fetch(categoryFetchRequest).first {
            // Если категория есть - связываем трекер с ней
            trackerCoreData.category = existingCategory
        } else {
            // Если категории нет - создаём новую
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.name = category.name
            trackerCoreData.category = newCategory
        }
        
        try context.save()
    }
    
    func deleteTracker(with id: UUID) throws {
        // Находим трекер по ID
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let tracker = try context.fetch(fetchRequest).first else {
            throw TrackerError.trackerNotFound
        }
        
        // Удаляем трекер и сохраняем изменения
        context.delete(tracker)
        try context.save()
    }
}
