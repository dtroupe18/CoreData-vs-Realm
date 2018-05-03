//
//  Item.swift
//  ToDo List
//
//  Created by Dave on 5/3/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    // Define the parent relationship -> Each item has one category
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    
    convenience init(title: String) {
        self.init()
        self.title = title
        self.done = false
        self.dateCreated = Date()
    }
}
