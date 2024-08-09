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
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context, delegate: delegate)
    }
    
    init(context: NSManagedObjectContext, delegate: TrackersViewController) {
        self.context = context
        self.delegate = delegate
    }
    

    private lazy var fetchResultController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
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
    
    private func addNewTracker(_ tracker: Tracker) {
        let trackerCoreData = TrackerCoreData(context: context)
        updateExistingTracker(trackerCoreData, with: tracker)
        saveContext()
    }
    
    private func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.trackerId = tracker.trackerId
        trackerCoreData.name = tracker.name
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule.joined(separator: ",")
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
    
//    private var numberOfSections: Int {
//        fetchResultController.sections?.count ?? 0
//    }
//
//    private func numberOfItemsInSection(_ section: Int) -> Int {
//        fetchResultController.sections?[section].numberOfObjects ?? 0
//    }
//
//    private func object(at indexPath: IndexPath) -> Tracker {
//        let trackerCoreData = fetchResultController.object(at: indexPath)
//        let tracker = Tracker(
//            trackerId: trackerCoreData.trackerId ?? UUID(),
//            name: trackerCoreData.name ?? "",
//            color:  UIColorMarshalling.shared.color(from: trackerCoreData.color ?? "#FFFFFF"),
//            emoji: trackerCoreData.emoji ?? "😂",
//            schedule: trackerCoreData.schedule?.split(separator: ",") as? [String] ?? ["Воскресенье"])
//        return tracker
//    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
}
