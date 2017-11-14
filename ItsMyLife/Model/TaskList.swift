//
//  TaskList.swift
//  RealmTasks
//
//  Created by Nathan Lambson on 11/07/2017.
//  Copyright (c) 2014 Alan Skipp. All rights reserved.
//

import RealmSwift


class TaskList: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var createdAt = NSDate()
    let tasks = List<Task>()
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}

