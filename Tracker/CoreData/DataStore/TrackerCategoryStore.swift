import UIKit
import CoreData

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private var currentDate: Date?
    private var searchText: String
    private weak var delegate: TrackersViewController?
    private var index: IndexPath?
    private let trackerStore = TrackerStore(delegate: TrackersViewController())
    
    convenience init(delegate: TrackersViewController, currentDate: Date?, searchText: String){
        let context = DataStore.shared.getContext()
        self.init(context: context, delegate: delegate, currentDate: currentDate, searchText: searchText)
    }
    
    init(context: NSManagedObjectContext, delegate: TrackersViewController, currentDate: Date?, searchText: String) {
        self.context = context
        self.delegate = delegate
        self.currentDate = currentDate
        self.searchText = searchText
    }
    
    private lazy var fetchedResultController: NSFetchedResultsController<TrackerCoreData> = {
        let currentDate = self.currentDate ?? Date()
        let weekday = DateFormatter.weekday(date: currentDate)
        let searchText = (self.searchText).lowercased()
        let fetchRequest = TrackerCoreData.fetchRequest()
        if searchText == "" {
            fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerCoreData.schedule), weekday)
        } else {
            fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[n] %@ AND %K CONTAINS[n] %@", #keyPath(TrackerCoreData.schedule), weekday, #keyPath(TrackerCoreData.name), searchText)
        }
        let sortDescriptor = NSSortDescriptor(key: #keyPath(TrackerCoreData.name), ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.trackerCategory.title),
            cacheName: nil)
        fetchedResultController.delegate = self
        try? fetchedResultController.performFetch()
        return fetchedResultController
    }()
    
    
    func createCategory(_ category: TrackerCategory) {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
        do {
            let existingCategories = try context.fetch(fetchRequest)
            if !existingCategories.isEmpty {
                print("Category with title \(category.title) already exists.")
                return
            }
            guard let entity = NSEntityDescription.entity(forEntityName: "TrackerCategoryCoreData", in: context) else { return }
            let categoryEntity = TrackerCategoryCoreData(entity: entity, insertInto: context)
            categoryEntity.title = category.title
            categoryEntity.trackers = NSSet(array: [])
            saveContext()
        } catch {
            print("Failed to fetch categories: \(error)")
        }
    }
    
    func deleteTrackerAndCategory(withID id: UUID, inCategory categoryName: String, tracker: Tracker){
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@ AND trackerCategory.title == %@", id as CVarArg, categoryName)
        do {
            let result = try context.fetch(fetchRequest)
            guard let trackerCoreData = result.first else {
                print("Tracker not found")
                return
            }
            deleteTracker(trackerCoreData: trackerCoreData)
            saveContext()
        } catch {
            print("Failed to fetch tracker: \(error)")
            return
        }
    }
    
    private func fetchCategory(title: String) -> TrackerCategoryCoreData? {
        return fetchAllCategories().first { $0.title == title }
    }
    
    func createCategoryAndTracker(tracker: Tracker, with titleCategory: String) {
        var category = fetchCategory(title: titleCategory)
        if category == nil {
            category = createCategory(with: titleCategory)
        }
        
        guard let trackerCoreData = trackerStore.addNewTracker(tracker) else { return }
        category?.addToTrackers(trackerCoreData)
        saveContext()
    }
    
    private func createCategory(with title: String) -> TrackerCategoryCoreData {
        guard let entity = NSEntityDescription.entity(forEntityName: "TrackerCategoryCoreData", in: context) else {
            fatalError("Failed to create entity description")
        }
        let newCategory = TrackerCategoryCoreData(entity: entity, insertInto: context)
        newCategory.title = title
        newCategory.trackers = NSSet(array: [])
        saveContext()
        return newCategory
    }
    func fetchAllCategories() -> [TrackerCategoryCoreData] {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        do {
            let categories = try context.fetch(fetchRequest)
            print("CATEGORIES")
            print(categories)
            return categories
        } catch let error as NSError {
            print("Could not fetch categories. \(error), \(error.userInfo)")
            return []
        }
    }
    
    func addTrackerToCategory(tracker: Tracker, with titleCategory: String) {
        let trackers = trackerStore.fetchTrackerCoreData()
        guard let existingCategory = fetchCategory(title: titleCategory) else { return }
        var existingTrackers = existingCategory.trackers?.allObjects as? [TrackerCoreData] ?? []
        if let trackerCoreData = trackers.first(where: {$0.trackerId == tracker.trackerId}) {
            if !existingTrackers.contains(where: { $0.trackerId == tracker.trackerId }) {
                existingTrackers.append(trackerCoreData)
            }
        }
        existingCategory.trackers = NSSet(array: existingTrackers)
        saveContext()
    }
    func decodingCategory(trackerCategoryCoreData: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let title = trackerCategoryCoreData.title else { return nil }
        let trackers = (trackerCategoryCoreData.trackers?.allObjects as? [TrackerCoreData])?.compactMap {
            trackerStore.decodingTracker(trackerCoreData: $0)
        } ?? []
        return TrackerCategory(title: title, trackers: trackers)
    }
    func getCategories() -> [TrackerCategory] {
        let categories: [TrackerCategory] = fetchAllCategories().map { categoryCoreData in
            let trackers = (categoryCoreData.trackers?.allObjects as? [TrackerCoreData])?.map { trackerCoreData in
                Tracker(
                    trackerId: trackerCoreData.trackerId ?? UUID(),
                    name: trackerCoreData.name ?? "",
                    color: UIColorMarshalling.shared.color(from: trackerCoreData.color ?? "#FFFFFF"),
                    emoji: trackerCoreData.emoji ?? "😃",
                    schedule: trackerCoreData.schedule?.components(separatedBy: ",") ?? ["Воскресенье"],
                    isPinned: trackerCoreData.isPinned
                )
            } ?? []
            return TrackerCategory(title: categoryCoreData.title ?? "", trackers: trackers)
        }
        return categories
    }
    func addNewTracker(categoryName: String, tracker: Tracker) {
        
        let trackerData = TrackerCoreData(context: context)
        trackerData.trackerId = tracker.trackerId
        trackerData.name = tracker.name
        trackerData.emoji = tracker.emoji
        trackerData.color = UIColorMarshalling.shared.hexString(from: tracker.color)
        trackerData.schedule = tracker.schedule.joined(separator: ",")
        trackerData.isPinned = tracker.isPinned
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == '\(categoryName)'", #keyPath(TrackerCategoryCoreData.title))
        if let category = try? context.fetch(request).first {
            trackerData.trackerCategory = category
        } else {
            let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
            trackerCategoryCoreData.title = categoryName
            trackerCategoryCoreData.addToTrackers(trackerData)
        }
        saveContext()
    }
    
    func updateDateAndSearchText(weekday: String, searchedText: String ) {
        if searchedText == "" {
            fetchedResultController.fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerCoreData.schedule), weekday)
            try? fetchedResultController.performFetch()
        } else {
            fetchedResultController.fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[c] %@ AND %K CONTAINS[c] %@", #keyPath(TrackerCoreData.schedule), weekday, #keyPath(TrackerCoreData.name), searchedText)
            try? fetchedResultController.performFetch()
        }
    }
    
    private func printCategoriesAndTrackers() {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        do {
            let categories = try context.fetch(fetchRequest)
            
            if categories.isEmpty {
                print("No categories found in Core Data.")
            } else {
                for category in categories {
                    printCategoryAndTrackers(category)
                }
            }
        } catch let error as NSError {
            print("Could not fetch categories. \(error), \(error.userInfo)")
        }
    }
    
    private func printCategoryAndTrackers(_ category: TrackerCategoryCoreData) {
        print("Category: \(category.title ?? "No Title")")
        if let trackers = category.trackers as? Set<TrackerCoreData>, !trackers.isEmpty {
            for tracker in trackers {
                print("Tracker ID: \(String(describing: tracker.trackerId))")
                print("Title: \(tracker.name ?? "No Title")")
                print("Color: \(UIColorMarshalling.shared.color(from: tracker.color ?? "#FFFFFF"))")
                print("emoji: \(tracker.emoji ?? "😃")")
                print("schedule: \(String(describing: tracker.schedule))")
            }
        } else {
            print("  No trackers in this category.")
        }
        print("---")
    }
    
    private func saveContext(){
        do{
            try context.save()
        } catch {
            print("Ошибка сохранения")
        }
    }
    
    var numberOfSections: Int {
        fetchedResultController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int{
        fetchedResultController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(_ indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultController.object(at: indexPath)
        let tracker = Tracker(
            trackerId: trackerCoreData.trackerId ?? UUID(),
            name: trackerCoreData.name ?? "",
            color: UIColorMarshalling.shared.color(from: trackerCoreData.color ?? "#FFFFFF"),
            emoji: trackerCoreData.emoji ?? "😂",
            schedule: trackerCoreData.schedule?.components(separatedBy: ",") ?? ["Воскресенье"],
            isPinned: trackerCoreData.isPinned
        )
        return tracker
    }
    
    func header(_ indexPath: IndexPath) -> String {
        let trackerCoreData = fetchedResultController.object(at: indexPath)
        guard let trackerHeader = trackerCoreData.trackerCategory?.title else {return "No category"}
        return trackerHeader
    }
    
    func deleteTrackerFromCategory(tracker: Tracker, with titleCategory: String) {
        guard let existingCategory = fetchCategory(title: titleCategory) else { return }
        guard var existingTrackers = existingCategory.trackers?.allObjects as? [TrackerCoreData] else { return }
        if let index = existingTrackers.firstIndex(where: { $0.trackerId == tracker.trackerId }) {
            existingTrackers.remove(at: index)
        }
        existingCategory.trackers = NSSet(array: existingTrackers)
        saveContext()
    }
    
    func fetchData() -> [TrackerCategory] {
        var trackerCategories: [TrackerCategory] = []
        let request = TrackerCoreData.fetchRequest()
        
        
        guard let trackerCoreData = try? context.fetch(request) else {return []}
        trackerCoreData.forEach( {tracker in
            let category = tracker.trackerCategory?.title ?? ""
            print(category)
            let tracker = Tracker(
                trackerId: tracker.trackerId ?? UUID(),
                name: tracker.name ?? "",
                color: UIColorMarshalling.shared.color(from: tracker.color ?? "#FFFFFF"),
                emoji: tracker.emoji ?? "😂",
                schedule: tracker.schedule?.components(separatedBy: ",") ?? ["Воскресенье"],
                isPinned: tracker.isPinned)
            
            print(tracker)
            
            if trackerCategories.contains(where: { trackerCategory in
                trackerCategory.title == category
            }) {
                var trackers: [Tracker] = []
                trackerCategories.forEach({
                    if $0.title == category {
                        trackers = $0.trackers
                        trackers.append(tracker)
                    }
                })
                trackerCategories.removeAll{ TrackerCategory in
                    TrackerCategory.title == category
                }
                
                trackerCategories.append(TrackerCategory(title: category, trackers: trackers))
            } else {
                let trackerCategory = TrackerCategory (
                    title: category,
                    trackers: [tracker]
                )
                trackerCategories.append(trackerCategory)
            }
        })
        return trackerCategories
    }
    
    func deleteCategory(withTitle title: String) {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        do {
            let categories = try context.fetch(fetchRequest)
            guard let categoryToDelete = categories.first else {
                print("Category with title \(title) not found.")
                return
            }
            if let trackers = categoryToDelete.trackers as? Set<TrackerCoreData>, !trackers.isEmpty {
                print("Category with title \(title) has associated trackers and cannot be deleted.")
                return
            }
            context.delete(categoryToDelete)
            saveContext()
            print("Category with title \(title) deleted successfully.")
        } catch {
            print("Failed to delete category with title \(title): \(error)")
        }
    }
    
    func loadCurrentTrackers(weekday: String, searchText: String) -> [TrackerCategory] {
        let request = TrackerCoreData.fetchRequest()
        
        if searchText == "" {
            request.predicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerCoreData.schedule), weekday)
        } else {
            request.predicate = NSPredicate(format: "%K CONTAINS[n] %@ AND %K CONTAINS[n] %@", #keyPath(TrackerCoreData.schedule), weekday, #keyPath(TrackerCoreData.name), searchText)
        }
        let trackerCoreData = try? context.fetch(request)
        var trackerCategories: [TrackerCategory] = []
        guard let trackerCoreData = trackerCoreData else { return [] }
        
        trackerCoreData.forEach({ tracker in
            let categoryName = tracker.trackerCategory?.title ?? ""
            print(categoryName)
            let tracker = Tracker(
                trackerId: tracker.trackerId ?? UUID(),
                name: tracker.name ?? "",
                color: UIColorMarshalling.shared.color(from: tracker.color ?? "#FFFFFF"),
                emoji: tracker.emoji ?? "😂",
                schedule: tracker.schedule?.components(separatedBy: ",") ?? ["Воскресенье"],
                isPinned: tracker.isPinned
            )
            
            print(tracker)
            if trackerCategories.contains(where: { trackerCategory in
                trackerCategory.title == categoryName
            }) {
                var trackers: [Tracker] = []
                trackerCategories.forEach({
                    if $0.title == categoryName {
                        trackers = $0.trackers
                        trackers.append(tracker)
                    }
                })
                trackerCategories.removeAll{ TrackerCategory in
                    TrackerCategory.title == categoryName
                }
                
                trackerCategories.append(TrackerCategory(title: categoryName, trackers: trackers))
            } else {
                let trackerCategory = TrackerCategory (
                    title: categoryName,
                    trackers: [tracker]
                )
                trackerCategories.append(trackerCategory)
            }
        })
        return trackerCategories
    }
    
    func isTrackersEmpty() -> Bool {
        let currentDate = self.currentDate ?? Date()
        let weekday = DateFormatter.weekday(date: currentDate)
        let searchedText = (self.searchText).lowercased()
        let request = TrackerCoreData.fetchRequest()
        
        if searchedText == "" {
            request.predicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerCoreData.schedule), weekday)
        } else {
            request.predicate = NSPredicate(format: "%K CONTAINS[n] %@ AND %K CONTAINS[n] %@", #keyPath(TrackerCoreData.schedule), weekday, #keyPath(TrackerCoreData.name), searchedText)
        }
        guard let trackerCoreData = try? context.fetch(request) else { return true}
        return trackerCoreData.isEmpty
    }
    
    func loadNotRegularIDTrackers() -> [UUID] {
        var uuids: [UUID] = []
        let request = TrackerCoreData.fetchRequest()
        
        let allDaysString = Weekdays.all()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.schedule), allDaysString)
        let trackerCoreData = try? context.fetch(request)
        guard let trackerCoreData = trackerCoreData else {return []}
        trackerCoreData.forEach({ tracker in
            
            let categoryName = tracker.trackerCategory?.title ?? ""
            if categoryName.contains(where: { character  in
                character == "😃"}) {
                print(categoryName)
                uuids.append(tracker.trackerId ?? UUID())
            }
        })
        return uuids
    }
    
    func deleteTracker(trackerCoreData: TrackerCoreData) {
        context.delete(trackerCoreData)
        saveContext()
        print("Tracker deleted successfully.")
    }
    
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        index = IndexPath()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let indexPath = index {
            delegate?.addTracker(indexPath: indexPath)
        }
        index = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                index = indexPath
            }
        default:
            break
        }
    }
}
