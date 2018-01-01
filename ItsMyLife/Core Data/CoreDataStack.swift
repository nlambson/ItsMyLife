//
//  CoreDataStack.swift
//  ItsMyLife
//
//  Created by Nathan Lambson on 11/07/2017.
//  Copyright (c) 2017 Nathan Lambson. All rights reserved.
//

import CoreData

class CoreDataStack {
    
    //  A void function that takes no parameters to be used for our callback when Core Data Main Context is saved.
    typealias Action = () -> ()
    var action: Action? = { }
    
    //  Singleton class
    static let shared = CoreDataStack()
    
    fileprivate var modelName: String!
    
    lazy var mainContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    lazy var storeContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Could not load stores.")
            }
        }
        
        return container
        
    }()
    
    func initializeCoreDataStack(modelName: String) -> Void {
        self.modelName = modelName
    }
    
}

extension CoreDataStack {
    
    //  Saves the main context if there are changes.
    func saveContext(completed: Action?) -> Void {
        
        guard mainContext.hasChanges else {
            completed?()
            return
        }
        
        do {
            try mainContext.save()
            completed?()
        } catch let error as NSError {
            // Couldn't save the context.
            completed?()
            print(error)
        }
        
    }
    
    //  If we need a context on a thread that is other than the main thread.
    func privateContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = CoreDataStack.shared.mainContext
        return context
    }
    
    //  If we need to have a child context somewhere instead of using the main context directly.
    func childContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = CoreDataStack.shared.mainContext
        return context
    }
    
}

