//
//  OrderTableViewController.swift
//  OrderApp
//
//  Created by Charday Neal on 1/25/24.
//

import UIKit

class OrderTableViewController: UITableViewController {

    var minutesToPrepareOrder = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //add edit button to nav bar
        navigationItem.leftBarButtonItem = editButtonItem
        
        tableView.rowHeight = 100.0
        
        
        //create an observer for notification
        NotificationCenter.default.addObserver(tableView!, selector: #selector(UITableView.reloadData), name: MenuController.orderUpdatedNotification, object: nil)
    

    }
    
    @IBSegueAction func confirmOrder(_ coder: NSCoder) -> OrderConfirmationViewController? {
        
        return OrderConfirmationViewController(coder: coder, minutesToPrepare: minutesToPrepareOrder)
    }
    
    @IBAction func unwindToOrderList(segue: UIStoryboardSegue) {
        
        if segue.identifier == "dismissConfirmation" {
            MenuController.shared.order.menuItems.removeAll()
        }
        
    }
    
    
    @IBAction func submitTapped(_ sender: Any) {
        
        //add all price items together
        let orderTotal = MenuController.shared.order.menuItems.reduce(0.0) { (result, menuItem) -> Double in
            return result + menuItem.price
        }
        
        //format to usd
        let formattedTotal = orderTotal.formatted(.currency(code: "usd"))
        
        //display alert once user taps submit
        let alert = UIAlertController(title: "Confirm Order", message: "You are about to submit your order with a total of \(formattedTotal)", preferredStyle: .actionSheet)
        
        //add an action to accept
        alert.addAction(UIAlertAction(title: "Submit Order", style: .default) {_ in self.uploadOrder()})
        
        //add an action to cancel
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func uploadOrder() {
        //collect menu id for all items in order
        let menuIds = MenuController.shared.order.menuItems.map { $0.id }
        
        //make POST network request
        Task.init {
            do {
                //store data from request
                let minutesToPrepare = try await MenuController.shared.submitOrder(forMenuIDs: menuIds)
                
                //update instance property with data
                minutesToPrepareOrder = minutesToPrepare
                
                performSegue(withIdentifier: "confirmOrder", sender: nil)
            } catch {
                displayError(error, title: "Order Submission Failed")
            }
        }
    }
    
    func displayError(_ error: Error, title: String) {
        // validate window
        guard let _ = viewIfLoaded?.window else {return}
        
        //display error to user
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        
        //add option to dismiss alert
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuController.shared.order.menuItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderItemCell", for: indexPath)

        // Configure the cell...
        configureCell(cell, forItemAt: indexPath)

        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, forItemAt indexPath: IndexPath) {
        let menuItem = MenuController.shared.order.menuItems[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = menuItem.name
        content.secondaryText = menuItem.price.formatted(.currency(code: "usd"))
        content.image = UIImage(systemName: "photo.on.rectangle")
        cell.contentConfiguration = content
    }
  

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        return true
    }
    

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //delete row from Menu Controller ordered items
            MenuController.shared.order.menuItems.remove(at: indexPath.row)
            
        }
    }


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
