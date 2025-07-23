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
    
    private func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        context.performAndWait { result = action(context) }
        return try result.get()
    }
    
    private func updateExistingCategory(
        trackerCategoryCoreData: TrackerCategoryCoreData,
        with category: TrackerCategory
    ) {
        trackerCategoryCoreData.name = category.name
    }
    
    func addNewCategory(_ category: TrackerCategory) throws {
        try performSync { context in
            Result {
                let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
                updateExistingCategory(trackerCategoryCoreData: trackerCategoryCoreData, with: category)
                try context.save()
            }
        }
    }
}
