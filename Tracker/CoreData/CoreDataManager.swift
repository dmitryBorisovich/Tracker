import CoreData

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    private init() {
        container = NSPersistentContainer(name: "TrackersModel")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
}
