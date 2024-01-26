//
//  MenuTableViewController.swift
//  OrderApp
//
//  Created by Charday Neal on 1/25/24.
//


import UIKit

@MainActor
class MenuTableViewController: UITableViewController {

    private let category: String
    var menuItems = [MenuItem]()
    
    var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    
    //custom initialization
    init?(coder: NSCoder, category: String) {
        self.category = category
        super.init(coder: coder)
    }
    
    //init method default should custom init fail
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = category.capitalized
        
        tableView.rowHeight = 100.0
        
        Task.init {
            do {
                let menuResponseItems = try await MenuController.shared.fetchMenuItems(forCategory: category)
                updateUI(with: menuResponseItems)
            } catch {
                displayError(error, title: "Failed to Fetch Menu Items for \(self.category)")
            }
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //cancel image fetching task that aren't needed
        imageLoadTasks.forEach { key, value in
            value.cancel()
        }
    }
    
    func updateUI(with menuItems: [MenuItem]) {
        self.menuItems = menuItems
        tableView.reloadData()
    }
    
    func displayError(_ error: Error, title: String) {
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBSegueAction func showMenuItem(_ coder: NSCoder, sender: Any?) -> MenuItemDetailViewController? {
        
        //validate cell as sender, and indexPath
        guard let cell = sender as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else {return nil}
        
        let selectedMenuItem = menuItems[indexPath.row]
        
        return MenuItemDetailViewController(coder: coder, menuItem: selectedMenuItem)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath)

        // Configure the cell...
        configureCell(cell, forCellAt: indexPath)
        
        return cell
    }

    func configureCell(_ cell: UITableViewCell, forCellAt indexPath: IndexPath) {
        
        guard let cell = cell as? MenuItemCell else {return}
        
        let menuItem = menuItems[indexPath.row]
        
        cell.itemName = menuItem.name
        cell.price = menuItem.price
        cell.image = nil
        
        imageLoadTasks[indexPath] = Task.init {
            if let image = try? await MenuController.shared.fetchImage(from: menuItem.imageURL) {
                if let currentIndexPath = self.tableView.indexPath(for: cell), currentIndexPath == indexPath {
                    cell.image = image
                }
            }
            imageLoadTasks[indexPath] = nil
        }
        
    }
    
    //cancel appropriate tasks
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //cancel image fetching task if not needed
        imageLoadTasks[indexPath]?.cancel()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


}
