//
//  MenuItemDetailViewController.swift
//  OrderApp
//
//  Created by Charday Neal on 1/25/24.
//

import UIKit

class MenuItemDetailViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var detailTextLabel: UILabel!
    @IBOutlet weak var addToOderButton: UIButton!
    
    
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

        updateUI()
    }
    

    func updateUI() {
        
        //update UI Labels
        nameLabel.text = menuItem.name
        priceLabel.text = menuItem.price.formatted(.currency(code: "usd"))
        detailTextLabel.text = menuItem.detailText
        
        Task.init{
            if let image = try? await MenuController.shared.fetchImage(from: menuItem.imageURL) {
                imageView.image = image
            }
        }
        
    }

    @IBAction func addToOrderTapped(_ sender: UIButton) {
       
        //animate uiview with bounce animation
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1,options: [], animations: {
            self.addToOderButton.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            
            self.addToOderButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: nil)
        
        //add menu item to order
        MenuController.shared.order.menuItems.append(menuItem)
    }
}
