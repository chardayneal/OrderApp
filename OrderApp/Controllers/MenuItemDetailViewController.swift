//
//  MenuItemDetailViewController.swift
//  OrderApp
//
//  Created by Charday Neal on 1/25/24.
//

import UIKit

class MenuItemDetailViewController: UIViewController {
    
    let menuItem: MenuItem
    
    //custom initilization
    init?(coder: NSCoder, menuItem: MenuItem) {
        self.menuItem = menuItem
        super.init(coder: coder)
    }
    
    //default init method should custom init fail
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = menuItem.name
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
