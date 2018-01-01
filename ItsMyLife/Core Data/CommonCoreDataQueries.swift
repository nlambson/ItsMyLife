//
//  CommonCoreDataQueries.swift
//  ItsMyLife
//
//  Created by Nathan Lambson on 11/07/2017.
//  Copyright (c) 2017 Nathan Lambson. All rights reserved.
//

import Foundation
import CoreData

class CommonQueries {
    
    //TODO Nathan build common coredata tasks
    class func fetchTask(forID taskID: Double, inContext context: NSManagedObjectContext) -> Task {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        let predicate = NSPredicate(format: "taskID = %@", taskID)
        request.predicate = predicate
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                return results.first as! Task
            } else {
                return Task(context: context)
            }
        } catch let err as NSError {
            print (err)
            return Task(context: context)
        }
        
    }   
}
