//
//  Item.swift
//  Todoey
//
//  Created by Sam on 10/9/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""    //dynamic : being monitored while running
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    //Relationship
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    
    required init() {
        self.dateCreated = Date()
    }
}
