//
//  CoreDataManager.swift
//  test_project
//
//  Created by Loyko, Artjom on 1/18/17.
//  Copyright © 2017 Loyko, Artjom. All rights reserved.
//



import Foundation
import CoreData

class CoreDataManager {
    // MARK: - Core Data stack
    
    static let sharedInstance = CoreDataManager()
    
    lazy var applicationDocumentsDirectoory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "VKModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectoory.appendingPathComponent("VKModel.sqlite")
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            print("ERROR: Failed to initialize persistentStoreCoordinator")
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: Core Data Saving context
    
    func saveContext() {
        
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print("ERROR: Failed to save context")
            }
            
        }
    }
    
//    func fetchRequest<Type: NSFetchRequestResult>(type: Type.Type, entityName: String) -> [Type]? {
//        let dialogFetch = NSFetchRequest<Type>(entityName: entityName)
//        
//        do {
//            let fetchedDialog = try managedObjectContext.fetch(dialogFetch)
//            print(fetchedDialog)
//            return fetchedDialog
//        } catch {
//            fatalError("Failed to fetch person: \(error)")
//        }
//        return nil
//    }
//    
//    
 
}
