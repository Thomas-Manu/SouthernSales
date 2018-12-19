//
//  PostViewController.swift
//  SouthernSales
//
//  Created by Thomas Manu on 11/18/18.
//  Copyright © 2018 Thomas Manu. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var priceText: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveNewPost(_ sender: Any) {
        if let title = titleText.text, let price = priceText.text, let description = descriptionText.text {
            let newPost = Listing.init(title: title, price: Double(price)!, description: description)
            Utility.databaseAddNewListing(with: newPost) { (error) in
                
            }
        }
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
