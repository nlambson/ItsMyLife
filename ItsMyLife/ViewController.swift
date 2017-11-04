//
//  ViewController.swift
//  ItsMyLife
//
//  Created by Nathan Lambson on 11/3/17.
//  Copyright © 2017 Nathan Lambson. All rights reserved.
//

import UIKit
import RealmSwift


// MARK: Model
final class TaskList: Object {
    @objc dynamic var text = ""
    @objc dynamic var id = ""
    let items = List<Task>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

final class Task: Object {
    @objc dynamic var text = ""
    @objc dynamic var completed = false
}


class ViewController: UITableViewController{

}
