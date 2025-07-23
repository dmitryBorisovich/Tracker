import Foundation
import CoreData

struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let insertedSections: IndexSet
    let deletedSections: IndexSet
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

protocol DataProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func tracker(at indexPath: IndexPath) -> Tracker?
    func sectionName(_ section: Int) -> String?
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws
    func deleteTracker(at indexPath: IndexPath) throws
    func updatePredicate(filterText: String?, date: Date)
//    func toggleTrackerRecord(record: TrackerRecord)
}

final class DataProvider: NSObject {
    
    private let colorMarshalling = UIColorMarshalling()
    private let scheduleMarshalling = ScheduleMarshalling()
    
    private let trackerStore: TrackerStore
//    private let categoryStore: TrackerCategoryStore
//    private let recordStore: TrackerRecordStore
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var insertedSections: IndexSet?
    private var deletedSections: IndexSet?
    
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
//        categoryStore: TrackerCategoryStore,
//        recordStore: TrackerRecordStore,
        delegate: DataProviderDelegate?
    ) throws {
        
        self.trackerStore = trackerStore
//        self.categoryStore = categoryStore
//        self.recordStore = recordStore
        self.delegate = delegate
    }
    
    
    
}

// MARK: - NSFetchedResultsControllerDelegate

extension DataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        insertedSections = IndexSet()
        deletedSections = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard
            let insertedIndexes, let deletedIndexes,
            let insertedSections, let deletedSections
        else { return }
        
        delegate?.didUpdate(
            TrackerStoreUpdate(insertedIndexes: insertedIndexes,
                               deletedIndexes: deletedIndexes,
                               insertedSections: insertedSections,
                               deletedSections: deletedSections)
        )
        
        self.insertedIndexes = nil
        self.deletedIndexes = nil
        self.insertedSections = nil
        self.deletedSections = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        switch type {
        case .insert:
            insertedSections?.insert(sectionIndex)
        case .delete:
            deletedSections?.insert(sectionIndex)
        default:
            break
        }
    }
}

// MARK: - DataProviderProtocol

extension DataProvider: DataProviderProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        let coreData = fetchedResultsController.object(at: indexPath)
        return trackerStore.convertToTracker(coreData)
    }
    
    func sectionName(_ section: Int) -> String? {
        fetchedResultsController.sections?[section].name
    }
    
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
        try trackerStore.addNewTracker(tracker, to: category)
    }

    func deleteTracker(at indexPath: IndexPath) throws {
        let tracker = fetchedResultsController.object(at: indexPath)
        try trackerStore.deleteTracker(tracker: tracker)
    }
    
    func updatePredicate(filterText: String?, date: Date) {
        let calendar = Calendar.current
        let pickerWeekday = calendar.component(.weekday, from: date)
        let filteredWeekday = pickerWeekday == 1 ? 7 : pickerWeekday - 1
        let pattern = String(format: "(^|,)%d(,|$)", filteredWeekday)
        
        // Удаляем кэш перед обновлением (важно при работе с секциями)
        NSFetchedResultsController<TrackerCoreData>.deleteCache(withName: fetchedResultsController.cacheName)
        
        // Базовый предикат для расписания
        var predicate = NSPredicate(format: "schedule CONTAINS %d OR schedule == nil", pattern)
        
        // Добавляем условие для поиска по тексту, если нужно
        if let searchText = filterText?.lowercased(), !searchText.isEmpty {
            predicate = NSPredicate(
                format: "(schedule CONTAINS %d OR schedule == nil) AND name CONTAINS[cd] %@",
                pattern,
                searchText
            )
        }
        
        fetchedResultsController.fetchRequest.predicate = predicate
        
        do {
            try fetchedResultsController.performFetch()
            
            // Формируем обновления для UI
            let update = TrackerStoreUpdate(
                insertedIndexes: IndexSet(),
                deletedIndexes: IndexSet(),
                insertedSections: IndexSet(),
                deletedSections: IndexSet()
            )
            delegate?.didUpdate(update)
            
        } catch {
            print("Ошибка при фильтрации трекеров: \(error.localizedDescription)")
        }
    }
}
