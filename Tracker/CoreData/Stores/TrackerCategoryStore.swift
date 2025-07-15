import CoreData

final class TrackerCategoryStore {
    
    private let context: NSManagedObjectContext
    
    convenience init() {
        let context = CoreDataManager.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewCategory(_ category: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        updateExistingCategory(trackerCategoryCoreData: trackerCategoryCoreData, with: category)
        try context.save()
    }
    
    func updateExistingCategory(trackerCategoryCoreData: TrackerCategoryCoreData, with category: TrackerCategory) {
        trackerCategoryCoreData.name = category.name
    }
}
