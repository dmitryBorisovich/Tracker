import CoreData

final class TrackerRecordStore {
    
    private let context: NSManagedObjectContext
    
    private let calendar = Calendar.current
    
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
    
//    func updateExistingTracker(_ record: TrackerRecordCoreData, with id: UUID) {
//        record.id = id
//    }
    
    func toggleTrackerRecord(record: TrackerRecord) throws {
        try performSync { context in
            Result {
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
        }
        
        
        
        //        let record = TrackerRecord(id: id, date: currentDate)
        //
        //        if completedTrackers.contains(record) {
        //            completedTrackers.remove(record)
        //        } else {
        //            completedTrackers.insert(record)
        //        }
    }
    
    func countTrackerRecords(for id: UUID) throws -> Int {
//        do {
//            return try performSync { context in
//                Result {
//                    let trackerRecordFetch = TrackerRecordCD.fetchRequest()
//                    trackerRecordFetch.resultType = .countResultType
//                    trackerRecordFetch.predicate = NSPredicate(format: "id == %@", id as NSUUID)
//                    let result = try context.count(for: trackerRecordFetch)
//                    return result
//                }
//            }
//        }
//        catch {
//            print("[TrackerRecordStore - amountOfRecords(for:)] Ошибка при подсчете выполненных трекеров: \(error.localizedDescription)")
//            return 0
//        }
        try performSync { context in
            Result {
                let trackerRecordFetch = TrackerRecordCoreData.fetchRequest()
                trackerRecordFetch.resultType = .countResultType
                trackerRecordFetch.predicate = NSPredicate(format: "id == %@", id as NSUUID)
                let result = try context.count(for: trackerRecordFetch)
                return result
            }
        }
    }
    
    func isTrackerCompletedToday(record: TrackerRecord) throws -> Bool {
        try performSync { context in
            Result {
                let trackerRecordFetch = TrackerRecordCoreData.fetchRequest()
                trackerRecordFetch.predicate = NSPredicate(
                    format: "id == %@ AND date == %@", record.id as NSUUID, record.date as NSDate
                )
                let result = try context.fetch(trackerRecordFetch)
                
                if result.isEmpty {
                    return false
                }
                else {
                    return true
                }
            }
        }
    }
    
}
