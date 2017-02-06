//
//  Trip.swift
//  MyCashCount
//
//  Created by Tiffany Chien on 4/17/15.
//  Copyright (c) 2015 Puppy Sized Elephants. All rights reserved.
//

import Foundation

class Trip: NSObject {
    var name: String
    var cost: Double
    var date: String
    
    init(name: String, cost: Double, date: String) {
        self.name = name
        self.cost = cost
        self.date = date
        super.init()
    }
}