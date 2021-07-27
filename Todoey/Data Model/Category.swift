//
//  Category.swift
//  Todoey
//
//  Created by Sam on 10/9/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""         //dynamic : being monitored while running
    @objc dynamic var color: String = ""
    
    //Relationship
    let items = List<Item>()  //Initialize with empty List of Item
}
