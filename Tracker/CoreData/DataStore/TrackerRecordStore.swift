import UIKit
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    convenience init(){
        let context = DataStore().getContext()
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func saveTrackerRecord(trackerRecord: TrackerRecord) {
        let trackerRecordData = TrackerRecordCoreData(context: context)
        trackerRecordData.trackerId = trackerRecord.trackerId
        trackerRecordData.trackerDate = trackerRecord.trackerDate
        saveContext()
    }
    
    func deleteRecord(id: UUID, currentDate: Date) {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.trackerId), id as NSUUID)
        if let recordsData = try? context.fetch(request) {
            recordsData.forEach { record in
                if let trackerRecordDate = record.trackerDate {
                    let isTheSameDay = Calendar.current.isDate(trackerRecordDate, inSameDayAs: currentDate)
                    if isTheSameDay {
                        context.delete(record)
                    }
                }
            }
        }
        saveContext()
    }
    func isCompletedTrackerRecords(id: UUID, date: Date) -> Bool {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(TrackerRecordCoreData.trackerId), id as NSUUID, #keyPath(TrackerRecordCoreData.trackerDate), date as NSDate)
        guard let recordsData = try? context.fetch(request) else {return false}
        return !recordsData.isEmpty
    }
    func completedTracker(id: UUID) -> Int {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.resultType = .countResultType
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.trackerId), id as NSUUID)
        
        if let count = try? context.execute(request) as? NSAsynchronousFetchResult<NSFetchRequestResult> {
            return count.finalResult?.first as! Int
        } else { return 0 }
    }
    func loadTrackers() -> [TrackerRecord] {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        guard let recordsData = try? context.fetch(request) else {return []}
        var trackerRecords: [TrackerRecord] = []
        recordsData.forEach {record in
            let trackerRecord = TrackerRecord(trackerId: record.trackerId ?? UUID(), trackerDate: record.trackerDate ?? Date())
            trackerRecords.append(trackerRecord)
        }
        return trackerRecords
    }
    
    func isTrackerCompleted(id: UUID, currentDate: Date) -> Bool{
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        
        request.predicate = NSPredicate(format: "%K == %@ AND %K < %@", #keyPath(TrackerRecordCoreData.trackerId), id as NSUUID, #keyPath(TrackerRecordCoreData.trackerDate), currentDate as NSDate)
        
        guard let recordsData = try? context.fetch(request) else { return false }
        
        if recordsData.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    private func saveContext(){
        do{
            try context.save()
        } catch {
            print("Ошибка сохранения")
        }
    }
}
