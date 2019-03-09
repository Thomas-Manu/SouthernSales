//
//  ViewListingViewController.swift
//  SouthernSales
//
//  Created by Thomas Manu on 1/21/19.
//  Copyright © 2019 Thomas Manu. All rights reserved.
//

import UIKit
import ImageSlideshow
import SnapKit

class ViewListingViewController: UIViewController {

    @IBOutlet weak var imageSlideshow: ImageSlideshow!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var savedButton: UIBarButtonItem!
    var listing: Listing!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.BackgroundColor
        navigationController?.navigationBar.tintColor = UIColor.white
        
        savedButton.image = listing.saved ? UIImage.init(named: "Heart") : UIImage.init(named: "Saved")
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnSlideshow))
        descriptionTextView.backgroundColor = Colors.BackgroundColor
        imageSlideshow.backgroundColor = Colors.BackgroundColor
        imageSlideshow.addGestureRecognizer(gestureRecognizer)
        imageSlideshow.setImageInputs([ImageSource(image: UIImage.init(named: "placeholder")!)])
        descriptionTextView.text = listing.descriptionString.replacingOccurrences(of: "\\n", with: "\n")
        getDownloadLinks()
    }
    
    override func updateViewConstraints() {
        if listing.imageRefs.count == 0 {
            descriptionTextView.snp.updateConstraints { (make) in
                make.top.equalTo(self.topLayoutGuide.snp.bottom)
            }
            imageSlideshow.removeFromSuperview()
        }
        
        super.updateViewConstraints()
    }
    
    @IBAction func messageSeller(_ sender: Any) {
    }

    @IBAction func saveListing(_ sender: Any) {
        if listing.saved {
            Utility.databaseRemoveFavorite(with: listing, success: {
                self.listing.saved.toggle()
                self.savedButton.image = UIImage.init(named: "Saved")
            }) { (error) in
                print("[VLVC] Failed to remove saved listing with ID \(String(describing: self.listing.reference?.documentID))")
            }
        } else {
            Utility.databaseAddNewFavorite(with: listing, success: {
                self.listing.saved.toggle()
                self.savedButton.image = UIImage.init(named: "Heart")
            }) { (error) in
                print("[VLVC] Failed to save listing with ID \(String(describing: self.listing.reference?.documentID))")
            }
        }
    }
    
    func getDownloadLinks() {
        Utility.cloudStorageGetImageURLs(from: listing, success: { (urls) in
            print("All urls: \(urls)")
            var imageSources = [SDWebImageSource]()
            for url in urls {
                imageSources.append(SDWebImageSource(url: url))
            }
            if urls.count != 0 {
                self.imageSlideshow.setImageInputs(imageSources)
            }
        }) { (error) in
            
        }
    }
    
    @objc func didTapOnSlideshow() {
        imageSlideshow.presentFullScreenController(from: self)
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
