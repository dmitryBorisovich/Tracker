import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: [TrackerStoreMove]
    let insertedSections: IndexSet
    let deletedSections: IndexSet
}

struct TrackerStoreMove {
    let oldIndex: Int
    let newIndex: Int
    let oldSection: Int
    let newSection: Int
}

final class TrackerStore: NSObject {
    
    enum TrackerError: Error {
        case trackerNotFound
    }
    
    private let context: NSManagedObjectContext
    private let colorMarshalling = UIColorMarshalling()
    private let scheduleMarshalling = ScheduleMarshalling()
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: [TrackerStoreMove]?
    private var insertedSections: IndexSet?
    private var deletedSections: IndexSet?
    
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
    
    weak var delegate: TrackerStoreDelegate?
    
    convenience override init() {
        let context = CoreDataManager.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = colorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        
        if let schedule = tracker.schedule {
            trackerCoreData.schedule = scheduleMarshalling.scheduleString(from: schedule)
        } else {
            trackerCoreData.schedule = nil
        }
    }
    
    private func convertToTracker(_ trackerCoreData: TrackerCoreData) -> Tracker {
        var schedule: [DaysOfWeek]?
        if let coreDataSchedule = trackerCoreData.schedule {
            schedule = scheduleMarshalling.schedule(from: coreDataSchedule)
        }
        
        return Tracker(
            id: trackerCoreData.id ?? UUID(),
            name: trackerCoreData.name ?? "",
            color: colorMarshalling.color(from: trackerCoreData.color ?? ""),
            emoji: trackerCoreData.emoji ?? "",
            schedule: schedule
        )
    }
    
    private func addNewTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateExistingTracker(trackerCoreData, with: tracker)
        
        let categoryFetchRequest = TrackerCategoryCoreData.fetchRequest()
        categoryFetchRequest.predicate = NSPredicate(format: "name == %@", category.name)
        
        if let existingCategory = try context.fetch(categoryFetchRequest).first {
            trackerCoreData.category = existingCategory
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.name = category.name
            trackerCoreData.category = newCategory
        }
        
        try context.save()
    }
    
    private func deleteTracker(tracker: TrackerCoreData) throws {
        context.delete(tracker)
        try context.save()
    }
}

extension TrackerStore {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        let coreData = fetchedResultsController.object(at: indexPath)
        return convertToTracker(coreData)
    }
    
    func sectionName(_ section: Int) -> String? {
        fetchedResultsController.sections?[section].name
    }
    
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
        try addNewTracker(tracker, to: category)
    }
    
    func deleteTracker(at indexPath: IndexPath) throws {
        let tracker = fetchedResultsController.object(at: indexPath)
        try deleteTracker(tracker: tracker)
    }
    
    func updatePredicate(filterText: String?, date: Date) {
        let calendar = Calendar.current
        let pickerWeekday = calendar.component(.weekday, from: date)
        let filteredWeekday = pickerWeekday == 1 ? 7 : pickerWeekday - 1
        let pattern = String(filteredWeekday)
        
        // Удаляем кэш перед обновлением
        NSFetchedResultsController<TrackerCoreData>.deleteCache(withName: fetchedResultsController.cacheName)
        
        // Базовый предикат для расписания
        var predicate = NSPredicate(format: "schedule CONTAINS %@ OR schedule == nil", pattern)
        
        // Добавляем условие для поиска по тексту
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
            
            let update = TrackerStoreUpdate(
                insertedIndexes: IndexSet(),
                deletedIndexes: IndexSet(),
                updatedIndexes: IndexSet(),
                movedIndexes: [],
                insertedSections: IndexSet(),
                deletedSections: IndexSet()
            )
            delegate?.didUpdate(update)
            
        } catch {
            print("Ошибка при фильтрации трекеров: \(error.localizedDescription)")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = []
        insertedSections = IndexSet()
        deletedSections = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let insertedIndexes = insertedIndexes,
              let deletedIndexes = deletedIndexes,
              let updatedIndexes = updatedIndexes,
              let movedIndexes = movedIndexes,
              let insertedSections = insertedSections,
              let deletedSections = deletedSections
        else { return }
        
        delegate?.didUpdate(TrackerStoreUpdate(
            insertedIndexes: insertedIndexes,
            deletedIndexes: deletedIndexes,
            updatedIndexes: updatedIndexes,
            movedIndexes: movedIndexes,
            insertedSections: insertedSections,
            deletedSections: deletedSections
        ))
        
        self.insertedIndexes = nil
        self.deletedIndexes = nil
        self.updatedIndexes = nil
        self.movedIndexes = nil
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
        case .insert:
            if let newIndexPath = newIndexPath {
                insertedIndexes?.insert(newIndexPath.item)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .update:
            if let indexPath = indexPath {
                updatedIndexes?.insert(indexPath.item)
            }
        case .move:
            if let oldIndexPath = indexPath, let newIndexPath = newIndexPath {
                movedIndexes?.append(TrackerStoreMove(
                    oldIndex: oldIndexPath.item,
                    newIndex: newIndexPath.item,
                    oldSection: oldIndexPath.section,
                    newSection: newIndexPath.section
                ))
            }
        @unknown default:
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
