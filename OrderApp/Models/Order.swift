//
//  Order.swift
//  OrderApp
//
//  Created by Charday Neal on 1/25/24.
//

import Foundation

//struct to contain list of items user has added
struct Order: Codable {
    
    var menuItems: [MenuItem]
    
    init(menuItems: [MenuItem] = []) {
        self.menuItems = menuItems
    }
}
