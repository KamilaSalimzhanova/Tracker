import UIKit
import CoreData

protocol TrackerStoreDelegateProtocol {
    func addTracker(indexPath: IndexPath)
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling.shared
    private weak var delegate: TrackersViewController?
    
    convenience init(delegate: TrackersViewController){
        let context = DataStore.shared.getContext()
        self.init(context: context, delegate: delegate)
    }
    
    init(context: NSManagedObjectContext, delegate: TrackersViewController) {
        self.context = context
        self.delegate = delegate
    }
    
    
    private lazy var fetchResultController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: false)
        ]
        
        let fetchResultedController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchResultedController.delegate = self
        try? fetchResultedController.performFetch()
        return fetchResultedController
    }()
    
    func fetchTrackerCoreData() -> [TrackerCoreData] {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let trackerCoreData = try! context.fetch(fetchRequest)
        return trackerCoreData
    }
    
    func addNewTracker(_ tracker: Tracker) -> TrackerCoreData? {
        let trackerCoreData = TrackerCoreData(context: context)
        updateExistingTracker(trackerCoreData, with: tracker)
        saveContext()
        return trackerCoreData
    }
    func fetchTracker(withID id: UUID) -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let result = try context.fetch(fetchRequest)
            return result.first
        } catch {
            return nil
        }
    }
    func decodingTracker(trackerCoreData : TrackerCoreData) -> Tracker? {
        guard let id = trackerCoreData.trackerId, let title = trackerCoreData.name,
              let color = trackerCoreData.color, let emoji = trackerCoreData.emoji, let schedule = trackerCoreData.schedule else { return nil }
        return Tracker(trackerId: id, name: title, color: UIColorMarshalling.shared.color(from: color), emoji: emoji, schedule: schedule.components(separatedBy: ","), isPinned: trackerCoreData.isPinned)
    }
    
    func getTrackerId(at indexPath: IndexPath) -> UUID? {
        let trackerCoreData = fetchResultController.object(at: indexPath)
        return trackerCoreData.trackerId
    }
    
    func changePin(trackerId: UUID, isPinned: Bool) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let tracker = results.first {
                tracker.isPinned = isPinned
                try context.save()
                print("Successfully changed pin status for tracker: \(trackerId) to \(isPinned)")
            } else {
                print("Tracker with ID \(trackerId) not found")
            }
        } catch {
            print("Failed to fetch or save tracker: \(error.localizedDescription)")
        }
    }

    
    private func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.trackerId = tracker.trackerId
        trackerCoreData.name = tracker.name
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule.joined(separator: ",")
        trackerCoreData.isPinned = tracker.isPinned
    }
    
    private func printTrackers() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        do {
            let trackers = try context.fetch(fetchRequest)
            
            if trackers.isEmpty {
                print("No trackers found in Core Data.")
            } else {
                print("Trackers in Core Data:")
                for tracker in trackers {
                    print("Tracker ID: \(String(describing: tracker.trackerId))")
                    print("Title: \(tracker.name ?? "No Title")")
                    print("Color: \(uiColorMarshalling.color(from: tracker.color ?? "#FFFFFF"))")
                    print("emoji: \(tracker.emoji ?? "😃")")
                    print("schedule: \(String(describing: tracker.schedule))")
                }
            }
        } catch let error as NSError {
            print("Could not fetch trackers. \(error), \(error.userInfo)")
        }
    }
    
    private func saveContext(){
        do{
            try context.save()
        } catch {
            print("Ошибка сохранения")
        }
    }
    
    private var numberOfSections: Int {
        fetchResultController.sections?.count ?? 0
    }
    
    private func numberOfItemsInSection(_ section: Int) -> Int {
        fetchResultController.sections?[section].numberOfObjects ?? 0
    }
    
    
    private func object(at indexPath: IndexPath) -> Tracker {
        let trackerCoreData = fetchResultController.object(at: indexPath)
        let tracker = Tracker(
            trackerId: trackerCoreData.trackerId ?? UUID(),
            name: trackerCoreData.name ?? "",
            color:  UIColorMarshalling.shared.color(from: trackerCoreData.color ?? "#FFFFFF"),
            emoji: trackerCoreData.emoji ?? "😂",
            schedule: trackerCoreData.schedule?.split(separator: ",") as? [String] ?? ["Воскресенье"],
            isPinned: trackerCoreData.isPinned)
        return tracker
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
}
