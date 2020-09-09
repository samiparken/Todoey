//
//  Item.swift
//  Todoey
//
//  Created by Sam on 9/8/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

class Item: Codable {  //Encodable, Decodable 
    var title: String = ""
    var Done: Bool = false
}
