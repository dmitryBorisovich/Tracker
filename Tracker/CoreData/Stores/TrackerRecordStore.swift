import CoreData

final class TrackerRecordStore {
    
    private let context: NSManagedObjectContext
    
    convenience init() {
        let context = CoreDataManager.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}
