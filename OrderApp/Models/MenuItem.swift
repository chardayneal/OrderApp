//
//  MenuItem.swift
//  OrderApp
//
//  Created by Charday Neal on 1/25/24.
//

import Foundation


//custom object type of decoded data from local server
struct MenuItem: Codable {
    var id: Int
    var name: String
    var detailText: String
    var price: Double
    var category: String
    var imageURL: URL
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case detailText = "description"
        case price
        case category
        case imageURL = "image_url"
    }
}
