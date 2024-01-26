//
//  ResponseModels.swift
//  OrderApp
//
//  Created by Charday Neal on 1/25/24.
//

import Foundation

//custom object of decoded data from network request with /menu path
struct MenuResponse: Codable {
    let items: [MenuItem]
}

//custom object of decoded data from network request with /categories path
struct CategoriesResponse: Codable {
    let categories: [String]
}

//custom object of data from POST method network request
struct OrderResponse: Codable {
    let prepTime: Int
    
    enum CodingKeys: String, CodingKey {
        case prepTime = "preparation_time"
    }
}
