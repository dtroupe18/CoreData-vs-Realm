//
//  AppDelegate.swift
//  ToDo List
//
//  Created by Dave on 5/2/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // print(realm.configuration.fileURL)
        do {
            _ = try Realm()
        } catch {
            print("Failed to initialize Realm on application launch: \(error)")
        }
        return true
    }
}

