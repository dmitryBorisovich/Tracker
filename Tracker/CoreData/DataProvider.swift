import Foundation
import CoreData

protocol DataProviderDelegate: AnyObject {
    
}

final class DataProvider: NSObject {
    
    private let colorMarshalling = UIColorMarshalling()
    private let scheduleMarshalling = ScheduleMarshalling()
    
//    enum DataProviderError: Error {
//        case failedToGetContext
//        case trackerNotFound
//        case categoryNotFound
//    }
//    
//    private let context: NSManagedObjectContext
//    private let dataStore: TrackerStore
    
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    
    weak var delegate: DataProviderDelegate?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataManager.shared.context,
            sectionNameKeyPath: "category.name",
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(
        trackerStore: TrackerStore,
        categoryStore: TrackerCategoryStore,
        recordStore: TrackerRecordStore,
        delegate: DataProviderDelegate?
    ) throws {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        self.delegate = delegate
    }
    
    
    
}

// MARK: - NSFetchedResultsControllerDelegate

extension DataProvider: NSFetchedResultsControllerDelegate {
    
}

// MARK: -

extension DataProvider {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCoreData? {
        fetchedResultsController.object(at: indexPath)
    }
    
//    func addTracker(_ tracker: TrackerStore) throws {
//        try? dataStore.add(tracker)
//    }
//    
//    func deleteRecord(at indexPath: IndexPath) throws {
//        let record = fetchedResultsController.object(at: indexPath)
//        try? dataStore.delete(record)
//    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return convertToTracker(trackerCoreData)
    }
    
    private func convertToTracker(_ coreData: TrackerCoreData) -> Tracker {
        Tracker(
            id: coreData.id ?? UUID(),
            name: coreData.name ?? "",
            color: colorMarshalling.color(from: coreData.color ?? ""),
            emoji: coreData.emoji ?? "",
            schedule: scheduleMarshalling.schedule(from: coreData.schedule ?? ""),
        )
    }
}
