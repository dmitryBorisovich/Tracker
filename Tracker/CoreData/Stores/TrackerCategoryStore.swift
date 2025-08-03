import CoreData

//struct TrackerCategoryStoreUpdate {
//    let insertedIndexes: IndexSet
//    let deletedIndexes: IndexSet
//}
//
//protocol TrackerCategoryStoreDelegate: AnyObject {
//    func didUpdate(_ update: TrackerCategoryStoreUpdate)
//}

final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    
    private let context: NSManagedObjectContext
    
//    private var insertedIndexes: IndexSet?
//    private var deletedIndexes: IndexSet?
    
//    weak var delegate: TrackerCategoryStoreDelegate?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataManager.shared.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    convenience override init() {
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
    
    func addNewCategory(_ category: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        updateExistingCategory(trackerCategoryCoreData: trackerCategoryCoreData, with: category)
        try context.save()
    }
    
    func editCategory(_ categoryName: String, newName: String) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", categoryName)
        let categories = try context.fetch(fetchRequest)

        guard let oldCategory = categories.first else { return }
        
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.name = newName

        if let trackers = oldCategory.trackers {
            newCategory.trackers = trackers
        }
        context.delete(oldCategory)

        try context.save()
    }
    
    func deleteCategory(_ categoryName: String) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", categoryName)
        let categories = try context.fetch(fetchRequest)
        categories.forEach { context.delete($0) }
        try context.save()
    }
    
    func countCategories() -> Int? {
        fetchedResultsController.fetchedObjects?.count
    }
    
    func fetchCategories() -> [TrackerCategoryCoreData]? {
        fetchedResultsController.fetchedObjects
    }
}

// MARK: - NSFetchedResultsControllerDelegate

//extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        insertedIndexes = IndexSet()
//        deletedIndexes = IndexSet()
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        guard let insertedIndexes,
//              let deletedIndexes
//        else { return }
//        
//        delegate?.didUpdate(
//            TrackerCategoryStoreUpdate(
//                insertedIndexes: insertedIndexes,
//                deletedIndexes: deletedIndexes
//            )
//        )
//        
//        self.insertedIndexes = nil
//        self.deletedIndexes = nil
//    }
//    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        
//        switch type {
//        case .delete:
//            if let indexPath = indexPath {
//                deletedIndexes?.insert(indexPath.item)
//            }
//        case .insert:
//            if let indexPath = newIndexPath {
//                insertedIndexes?.insert(indexPath.item)
//            }
//        default:
//            break
//        }
//    }
//}
