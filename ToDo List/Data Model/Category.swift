//
//  Category.swift
//  ToDo List
//
//  Created by Dave on 5/3/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    
    // Define the child relationship -> Each category can have many Items
    let items = List<Item>()
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
