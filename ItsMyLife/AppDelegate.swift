d//
//  AppDelegate.swift
//  RealmTasks
//
//  Created by Nathan Lambson on 11/07/2017.
//  Copyright (c) 2014 Alan Skipp. All rights reserved.
//

import UIKit
import RealmSwift

let uiRealm = try! Realm()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
}

