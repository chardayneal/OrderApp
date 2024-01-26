//
//  MenuController.swift
//  OrderApp
//
//  Created by Charday Neal on 1/25/24.
//

import UIKit

class MenuController {
    
    //create shared instance of controller
    static let shared = MenuController()
    
    //property name of notification
    static let orderUpdatedNotification = Notification.Name("MenuController.orderUpdated")
    
    
    //whenever anything changes, all observers will have a chance to react
    var order = Order() {
        didSet {
            NotificationCenter.default.post(name: MenuController.orderUpdatedNotification, object: nil)
        }
    }
    
    //initialize URL instance with local server address
    let baseURL = URL(string: "http://localhost:8080/")!
    
    //custom error should network request fail to retrieve data
    enum MenuControllerError: Error, LocalizedError {
        case categoriesNotFound, menuItemsnotFound, orderRequestFailed, imageDataMissing
    }
    
    func fetchCategories() async throws -> [String] {
        //create a url with the file path to list of categories
        let url = baseURL.appendingPathComponent("categories")
        
        //make network request with URL
        let (data, response) = try await URLSession.shared.data(from: url)
        
        //validate response as expected else throw custom error
        guard let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode == 200 else {
            throw MenuControllerError.categoriesNotFound
        }
        
        let jsonDecoder = JSONDecoder()
        let categoriesResponse = try jsonDecoder.decode(CategoriesResponse.self, from: data)
        
        return categoriesResponse.categories
        
    }
    
    func fetchMenuItems(forCategory categoryName: String) async throws -> [MenuItem] {
        //create url with file path to list of categories
        let baseMenuURL = baseURL.appendingPathComponent("menu")
        
        
        //add query from user to url
        var urlComponents = URLComponents(url: baseMenuURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [URLQueryItem(name: "category", value: categoryName)]

        //make network request with URL
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        
        //validate response of network request else throw custom error
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MenuControllerError.menuItemsnotFound
        }
        
        //initialize decoder and store decoded data into MenuResponse object
        let jsonDecoder = JSONDecoder()
        let menuItems = try jsonDecoder.decode(MenuResponse.self, from: data)
        
        return menuItems.items
        
    }
    
    func fetchImage(from url: URL) async throws -> UIImage {
        //make a network request
        let (data, response) = try await URLSession.shared.data(from: url)
        
        //validate response to network request else throw custom error
        guard let httpResponse  = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MenuControllerError.imageDataMissing
        }
        
        //validate conversion into UIImage
        guard let image = UIImage(data: data) else {
            throw MenuControllerError.imageDataMissing
        }
        
        return image

    }
    
    typealias MinutesToPrepare = Int
    
    func submitOrder(forMenuIDs menuIDs: [Int]) async throws -> MinutesToPrepare {
        let orderURL = baseURL.appendingPathComponent("order")
       
        //initialize URLRequest and modify request type
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //declare data to be encoded
        let menuIdsDict = ["menuIds": menuIDs]
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(menuIdsDict)
        
        //assign encoded data to body of request and make the network request
        request.httpBody = jsonData
        let (data, response) = try await URLSession.shared.data(for: request)
        
        //validate network response or throw appropriate error
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MenuControllerError.orderRequestFailed
        }
        
        //decode validated data into order response object
        let jsonDecoder = JSONDecoder()
        let orderResponse = try jsonDecoder.decode(OrderResponse.self, from: data)
        
        return orderResponse.prepTime
    }
}
