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
        // TODO: реализовать добавление новой категории
        try context.save()
    }
    
}
