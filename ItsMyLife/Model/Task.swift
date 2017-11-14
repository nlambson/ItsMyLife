//
//  Task.swift
//  RealmTasks
//
//  Created by Nathan Lambson on 11/07/2017.
//  Copyright (c) 2014 Alan Skipp. All rights reserved.
//

import RealmSwift

class Task: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var createdAt = NSDate()
    @objc dynamic var notes = ""
    @objc dynamic var isCompleted = false
    
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}

