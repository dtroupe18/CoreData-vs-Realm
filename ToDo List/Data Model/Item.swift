//
//  Item.swift
//  ToDo List
//
//  Created by Dave on 5/2/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation

struct Item {
    
    var title: String
    var done: Bool
    
    init(title: String) {
        self.title = title
        self.done = false
    }
    
    init(title: String, done: Bool) {
        self.title = title
        self.done = done
    }
}
