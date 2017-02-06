//
//  Item.swift
//  MyCashCount
//
//  Created by Tiffany Chien on 3/29/15.
//  Copyright (c) 2015 Puppy Sized Elephants. All rights reserved.
//

import Foundation

class Item: NSObject {
    var name: String
    var cost: Double
    var quantity: Int
    
    init(name: String, cost: Double, quantity: Int) {
        self.name = name
        self.cost = cost
        self.quantity = quantity
        super.init()
    }
}