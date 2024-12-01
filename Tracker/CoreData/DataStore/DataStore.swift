import Foundation
import CoreData

final class DataStore{
    
    static let shared = DataStore()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LibraryCoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func getContext() -> NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    
}
