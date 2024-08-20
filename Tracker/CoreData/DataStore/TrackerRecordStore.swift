import UIKit
import CoreData


final class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \TrackerRecordCoreData.trackerDate, ascending: true) ]
        let fetchResultedController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchResultedController.delegate = self
        try? fetchResultedController.performFetch()
        return fetchResultedController
    }()
    
    convenience override init(){
        let context = DataStore.shared.getContext()
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func saveTrackerRecord(trackerRecord: TrackerRecord) {
        guard let entity = NSEntityDescription.entity(forEntityName: "TrackerRecordCoreData", in: context) else { return }
        let newRecord = TrackerRecordCoreData(entity: entity, insertInto: context)
        newRecord.trackerId = trackerRecord.trackerId
        newRecord.trackerDate = trackerRecord.trackerDate
        saveContext()
    }
    
    func fetchRecords() -> [TrackerRecord] {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let trackerRecordCoreDataArray = try! context.fetch(fetchRequest)
        let trackerRecords = trackerRecordCoreDataArray.map { trackerRecordCoreData in
            return TrackerRecord(
                trackerId: trackerRecordCoreData.trackerId ?? UUID(),
                trackerDate: trackerRecordCoreData.trackerDate ?? Date()
            )
        }
        return trackerRecords
    }
    
    func getTrackerRecordCount() throws -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    func deleteRecord(id: UUID, currentDate: Date) {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@", id as CVarArg)
        if let recordsData = try? context.fetch(request) {
            recordsData.forEach { record in
                if let trackerRecordDate = record.trackerDate {
                    let isTheSameDay = Calendar.current.isDate(trackerRecordDate, inSameDayAs: currentDate)
                    if isTheSameDay {
                        context.delete(record)
                        print("Record deleted: \(record)")
                        saveContext()
                    }
                }
            }
        }
        saveContext()
    }
    func deleteTracker(tracker: Tracker) {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@", tracker.trackerId as CVarArg)
        do {
            let records = try context.fetch(fetchRequest)
            for record in records {
                context.delete(record)
            }
            saveContext()
        } catch {
            print("Error deleting records: \(error.localizedDescription)")
        }
    }
    func isCompletedTrackerRecords(id: UUID, date: Date) -> Bool {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(TrackerRecordCoreData.trackerId), id as NSUUID, #keyPath(TrackerRecordCoreData.trackerDate), date as NSDate)
        guard let recordsData = try? context.fetch(request) else {return false}
        return !recordsData.isEmpty
    }
    func completedTracker(id: UUID) -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        request.resultType = .countResultType
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.trackerId), id as NSUUID)
        
        if let count = try? context.execute(request) as? NSAsynchronousFetchResult<NSFetchRequestResult> {
            return count.finalResult?.first as! Int
        } else { return 0 }
    }
    func loadTrackers() -> [TrackerRecord] {
        let request = TrackerRecordCoreData.fetchRequest()
        guard let recordsData = try? context.fetch(request) else {return []}
        var trackerRecords: [TrackerRecord] = []
        recordsData.forEach {record in
            let trackerRecord = TrackerRecord(trackerId: record.trackerId ?? UUID(), trackerDate: record.trackerDate ?? Date())
            trackerRecords.append(trackerRecord)
        }
        return trackerRecords
    }
    
    func isTrackerCompleted(id: UUID, currentDate: Date) -> Bool{
        let request = TrackerRecordCoreData.fetchRequest()
        
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
