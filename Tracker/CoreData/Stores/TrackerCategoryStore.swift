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
    
    private func updateExistingCategory(
        trackerCategoryCoreData: TrackerCategoryCoreData,
        with category: TrackerCategory
    ) {
        trackerCategoryCoreData.name = category.name
    }
    
    private func addNewCategory(_ category: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        updateExistingCategory(trackerCategoryCoreData: trackerCategoryCoreData, with: category)
        try context.save()
    }
}

//private func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
//    let context = self.context
//    var result: Result<R, Error>!
//    context.performAndWait { result = action(context) }
//    return try result.get()
//}
