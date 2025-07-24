import CoreData

final class TrackerRecordStore {
    
    // MARK: - Properties
    
    private let context: NSManagedObjectContext
    private let calendar = Calendar.current
    
    // MARK: - Init
    
    convenience init() {
        let context = CoreDataManager.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Methods
    
    func toggleTrackerRecord(record: TrackerRecord) throws {
        let date = calendar.startOfDay(for: record.date)
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "id == %@ AND date == %@", record.id as NSUUID, date as NSDate
        )
        
        let results = try context.fetch(fetchRequest)
        
        if let existingRecord = results.first {
            context.delete(existingRecord)
        } else {
            let newRecord = TrackerRecordCoreData(context: context)
            newRecord.id = record.id
            newRecord.date = date
        }
        
        try context.save()
    }
    
    func countTrackerRecords(for id: UUID) throws -> Int {
        let trackerRecordFetch = TrackerRecordCoreData.fetchRequest()
        trackerRecordFetch.resultType = .countResultType
        trackerRecordFetch.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        let result = try context.count(for: trackerRecordFetch)
        return result
    }
    
    func isTrackerCompletedToday(record: TrackerRecord) throws -> Bool {
        let trackerRecordFetch = TrackerRecordCoreData.fetchRequest()
        trackerRecordFetch.predicate = NSPredicate(
            format: "id == %@ AND date == %@", record.id as NSUUID, record.date as NSDate
        )
        let result = try context.fetch(trackerRecordFetch)
        
        return !result.isEmpty
    }
}
