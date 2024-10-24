import Foundation
import CoreData

// Bad: Global state and singleton
class DataManager {
    static let shared = DataManager()
    
    // Bad: Force unwrapped persistent container
    private let persistentContainer: NSPersistentContainer!
    
    // Bad: Public mutable state
    var saveCallback: (() -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    // Bad: Multiple responsibilities
    private var memoryCache: [String: Any] = [:]
    private var backgroundTasks: [UUID: Progress] = [:]
    
    // Bad: Complex initialization
    private init() {
        persistentContainer = NSPersistentContainer(name: "DataModel")
        persistentContainer.loadPersistentStores { description, error in
            // Bad: Force unwrap in initialization
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        
        // Bad: Setup in init
        setupNotifications()
        clearCache()
    }
    
    // Bad: Notification handling
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(handleMemoryWarning),
                                             name: UIApplication.didReceiveMemoryWarningNotification,
                                             object: nil)
    }
    
    // MARK: - Core Data Operations
    
    // Bad: Error handling with optionals
    func saveContext() -> Bool {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                saveCallback?()
                return true
            } catch {
                // Bad: Error handling
                print("Error saving context: \(error)")
                errorHandler?(error)
                return false
            }
        }
        return true
    }
    
    // Bad: Generic fetch without type safety
    func fetchEntities<T: NSManagedObject>(_ entityName: String) -> [T]? {
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<T>(entityName: entityName)
        
        // Bad: Try catch with force try
        return try! context.fetch(request)
    }
    
    // Bad: Complex method with multiple responsibilities
    func saveEntity(_ entityName: String, attributes: [String: Any]) -> NSManagedObject? {
        let context = persistentContainer.viewContext
        
        // Bad: Force unwrapping
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            return nil
        }
        
        let managedObject = NSManagedObject(entity: entity, insertInto: context)
        
        // Bad: Type casting and error handling
        for (key, value) in attributes {
            managedObject.setValue(value, forKey: key)
        }
        
        // Bad: Nested error handling
        do {
            try context.save()
            
            // Bad: Cache management mixed with saving
            memoryCache[entityName + "\(attributes.hashValue)"] = managedObject
            
            return managedObject
        } catch {
            context.rollback()
            errorHandler?(error)
            return nil
        }
    }
    
    // Bad: Redundant delete method
    func deleteEntity(_ object: NSManagedObject) -> Bool {
        let context = persistentContainer.viewContext
        
        // Bad: Error handling
        context.delete(object)
        
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            errorHandler?(error)
            return false
        }
    }
    
    // MARK: - Cache Management
    
    // Bad: Cache implementation
    func setCacheValue(_ value: Any, forKey key: String) {
        memoryCache[key] = value
    }
    
    func getCacheValue(forKey key: String) ->
