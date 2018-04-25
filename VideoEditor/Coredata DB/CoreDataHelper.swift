//
//  CoreDataHelper.swift
//  VideoEditor

import Foundation
import CoreData


class CoreDataHelperInstance {
    class var sharedInstance: CoreDataHelper {
        struct Static {
            static let instance: CoreDataHelper = CoreDataHelper()
        }
        return Static.instance
    }
}
class CoreDataHelper : NSObject
{
    let storeName = "VideoEditorDB"
    let storeFilename = "VideoEditor.sqlite"
    var manageObjectContext: NSManagedObjectContext!
    var manageObjectModel: NSManagedObjectModel!
    var persistentCoordinator: NSPersistentStoreCoordinator!
    
    override init() {
        super.init()
    }
    var applicationDocumentDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        
        var libraryURL: URL = urls[urls.count - 1]
        
        var strLibPath = libraryURL.path
        strLibPath = strLibPath + "/VideoEditorDB"
        if !FileManager.default.fileExists(atPath: strLibPath)
        {
            do
            {
                try FileManager.default.createDirectory(atPath: strLibPath, withIntermediateDirectories: true, attributes: nil)
            }
            catch
            {
                
            }
        }
        let strFinalURL: URL = URL.init(fileURLWithPath: strLibPath)
        return strFinalURL
    }()
    func manageObjectContext1() -> NSManagedObjectContext
    {
        if (self.manageObjectContext != nil)
        {
            return self.manageObjectContext
        }
        let coordinator: NSPersistentStoreCoordinator? = self.persistentStore()
        if (coordinator != nil)
        {
            self.manageObjectContext = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
            self.manageObjectContext.persistentStoreCoordinator = coordinator
        }
        
        return self.manageObjectContext
    }
    func maangeObjectModel1() -> NSManagedObjectModel
    {
        if( self.manageObjectModel != nil)
        {
            return self.manageObjectModel
        }
        let modelURL: URL? = Bundle.main.url(forResource: "VideoEditor", withExtension: "momd")! as URL
        self.manageObjectModel = NSManagedObjectModel.init(contentsOf: modelURL!)
        return self.manageObjectModel
        
    }
    func persistentStore() -> NSPersistentStoreCoordinator
    {
        if self.persistentCoordinator != nil
        {
            return self.persistentCoordinator
        }
        let storeURL: URL = self.applicationDocumentDirectory.appendingPathComponent(storeFilename)
        self.persistentCoordinator = NSPersistentStoreCoordinator.init(managedObjectModel: self.maangeObjectModel1())
        do {
             try self.persistentCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
//            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return self.persistentCoordinator
        
    }
    func saveContext() {
        let context: NSManagedObjectContext = self.manageObjectContext
        
        if context.hasChanges
        {
            do {
                
                try context.save()
            } catch _ as NSError {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
            
        }
    }
    func fetchDataFrom(entityName1: String, sorting : Bool, predicate: NSPredicate?) -> Array<Any>? {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: entityName1)
        if (predicate != nil)
        {
            fetchRequest.predicate = predicate
        }
        
        let sortDiscriptor: NSSortDescriptor = NSSortDescriptor.init(key: "tagIndex", ascending: true)
        fetchRequest.sortDescriptors = [sortDiscriptor]
        var array: [AnyObject]?
        do
        {
            array = try self.manageObjectContext?.fetch(fetchRequest)
        }
        catch {
        }
        
        return array
    }
    func fetchDataFrom(entityName1: String, sorting : Bool, predicate: NSPredicate?, sortKey: String) -> Array<Any>? {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: entityName1)
        if (predicate != nil)
        {
            fetchRequest.predicate = predicate
        }
        
        let sortDiscriptor: NSSortDescriptor = NSSortDescriptor.init(key: sortKey, ascending: sorting)
        fetchRequest.sortDescriptors = [sortDiscriptor]
        var array: [AnyObject]?
        do
        {
            array = try self.manageObjectContext?.fetch(fetchRequest)
        }
        catch {
        }
        
        return array
    }
    func DeleteAllDataFromDB()
    {
        // Initialize Fetch Request
        let entityArray = ["TagInfo"]
        for item in entityArray
        {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: item)
            
            // Configure Fetch Request
            fetchRequest.includesPropertyValues = false
            
            do {
                let items = try self.manageObjectContext.fetch(fetchRequest) as! [NSManagedObject]
                
                for item in items
                {
                    self.manageObjectContext.delete(item)
                }
                
                // Save Changes
                
            }
            catch
            {
                // Error Handling
                // ...
            }
        }
        self.saveContext()
    }
}
