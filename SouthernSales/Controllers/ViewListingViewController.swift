//
//  ViewListingViewController.swift
//  SouthernSales
//
//  Created by Thomas Manu on 1/21/19.
//  Copyright © 2019 Thomas Manu. All rights reserved.
//

import UIKit
import ImageSlideshow

class ViewListingViewController: UIViewController {

    @IBOutlet weak var imageSlideshow: ImageSlideshow!
    @IBOutlet weak var descriptionTextView: UITextView!
    var listing: Listing!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.white
        
        descriptionTextView.text = listing.description.replacingOccurrences(of: "\\n", with: "\n")
    }
    
    @IBAction func messageSeller(_ sender: Any) {
    }

    @IBAction func saveListing(_ sender: Any) {
        Utility.databaseAddNewFavorite(with: listing) { (error) in
            print("[VLVC] Failed to save listing with ID \(String(describing: self.listing.reference?.documentID))")
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
