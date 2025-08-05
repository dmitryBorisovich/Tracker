import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate()
}

final class TrackerCategoryStore: NSObject {
    
    private let context: NSManagedObjectContext
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
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
    
    private func isNameUsed(name: String) -> Bool {
        let trackerCategories = fetchedResultsController.fetchedObjects ?? []
        return trackerCategories.contains(where: { $0.name == name })
    }
    
    func addNewCategory(_ category: TrackerCategory) throws {
        if isNameUsed(name: category.name) {
            throw CategoryError.duplicateName
        }
        
        let trackerCategoryCD = TrackerCategoryCoreData(context: context)
        updateExistingCategory(
            trackerCategoryCoreData: trackerCategoryCD,
            with: category
        )
        do {
            try context.save()
        } catch {
            throw CategoryError.addError
        }
    }
    
    func editCategory(at index: IndexPath, newName: String) throws {
        if isNameUsed(name: newName) {
            throw CategoryError.duplicateName
        }
        
        let categoryToEdit = fetchedResultsController.object(at: index)
        categoryToEdit.name = newName
        do {
            try context.save()
        } catch {
            throw CategoryError.editError
        }
    }
    
    func deleteCategory(at index: IndexPath) throws {
        let categoryToDelete = fetchedResultsController.object(at: index)
        context.delete(categoryToDelete)
        do {
            try context.save()
        } catch {
            throw CategoryError.deleteError
        }
    }
    
    func countCategories() -> Int? {
        fetchedResultsController.fetchedObjects?.count
    }
    
    func fetchCategory(at index: IndexPath) -> TrackerCategoryCoreData {
        fetchedResultsController.object(at: index)
    }
    
    func fetchCategories() -> [TrackerCategoryCoreData]? {
        fetchedResultsController.fetchedObjects
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        delegate?.didUpdate()
    }
}
