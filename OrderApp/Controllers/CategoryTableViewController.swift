//
//  CategoryTableViewController.swift
//  OrderApp
//
//  Created by Charday Neal on 1/25/24.
//

import UIKit

@MainActor
class CategoryTableViewController: UITableViewController {

    var categories = [String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 110.0

        Task.init {
            do {
                // perform request for categories
                let fetchedCategories = try await MenuController.shared.fetchCategories()
                updateUI(with: fetchedCategories)
            } catch {
                displayError(error, title: "Failed to Fetch Categories")
            }
        }
    }
    
    func updateUI(with categories: [String]) {
        //populate tableview with appropriate category items
        self.categories = categories
        self.tableView.reloadData()
    }
    
    func displayError(_ error: Error, title: String) {
        guard let _ = viewIfLoaded?.window else {return}
        
        //display alert to user
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        
        //allow user to dismiss alert
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBSegueAction func showMenu(_ coder: NSCoder, sender: Any?) -> MenuTableViewController? {
        
        //validate whether sender is uitableview cell and indexpath from selected cell
        guard let cell = sender as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return nil}
        
        let selectedCategory = categories[indexPath.row]
        return MenuTableViewController(coder: coder, category: selectedCategory)

    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)

        configureCell(cell, forCategoryAt: indexPath)

        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, forCategoryAt indexPath: IndexPath) {
        
        // Configure current cell
        let category = categories[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = category.capitalized
        cell.contentConfiguration = content
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
