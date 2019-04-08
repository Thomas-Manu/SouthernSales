//
//  PostViewController.swift
//  SouthernSales
//
//  Created by Thomas Manu on 11/18/18.
//  Copyright © 2018 Thomas Manu. All rights reserved.
//

import UIKit
import YPImagePicker
import ImageSlideshow

class PostViewController: UIViewController {

    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var priceText: UITextField!
    @IBOutlet weak var descriptionView: FloatLabelTextView!
    @IBOutlet weak var imageSlideshow: ImageSlideshow!
    @IBOutlet weak var resetButton: UIBarButtonItem!
    @IBOutlet weak var previewButton: UIButton!
    
    var images = [UIImage]()
    var listing: Listing? = nil
    var isUpdating = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.BackgroundColor
        navigationController?.navigationBar.barStyle = .black
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnSlideshow))
        imageSlideshow.addGestureRecognizer(gestureRecognizer)
        imageSlideshow.setImageInputs([ImageSource(image: UIImage.init(named: "placeholder")!)])
        imageSlideshow.backgroundColor = Colors.BackgroundColor
        
        if isUpdating, let listing = listing {
            title = "Update Listing"
            resetButton.title = "Cancel"
            previewButton.setTitle("Update", for: .normal)
            titleText.text = listing.title
            priceText.text = String(describing: listing.price)
            descriptionView.text = listing.descriptionString
            getDownloadLinks()
        }
    }
    
    @IBAction func resetPost(_ sender: Any) {
        if isUpdating {
            dismiss(animated: true, completion: nil)
        } else {
            titleText.text = ""
            priceText.text = ""
            descriptionView.text = ""
            images.removeAll()
            imageSlideshow.setImageInputs([ImageSource(image: UIImage.init(named: "placeholder")!)])
        }
    }
    
    @IBAction func saveNewPost(_ sender: Any) {
        guard let title = titleText.text, let price = priceText.text, let description = descriptionView.text else {
            return
        }
        var message = ""
        if title.count == 0 {
            message.append("• Title is required.\n")
        }
        if price.count == 0 {
            message.append("• Price is required.\n")
        }
        if description.count == 0 {
            message.append("• Description is required.")
        }
        if message.count != 0 {
            let alert = UIAlertController.init(title: "Missing Information", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        } else if isUpdating, let listing = listing {
            if images.count > 0 {
                
            }
            let updatedPost = Listing.init(title: title, price: Double(price)!, description: description, user: listing.user, imageRefs: listing.imageRefs, reference: listing.reference, saved: false)
            Utility.databaseUpdateListing(updatedPost, success: {
                self.dismiss(animated: true, completion: nil)
            }) { (error) in
                print("[PVC] Error updating listing: \(error)")
            }
        } else {
            let newPost = Listing.init(title: title, price: Double(price)!, description: description, imageRefs: [])
            performSegue(withIdentifier: Constants.PreviewSegue, sender: newPost)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vlvc = segue.destination as! ViewListingViewController
        let listing = sender as! Listing
        vlvc.title = listing.title
        vlvc.listing = listing
        vlvc.isPreview = true
        vlvc.images = images
    }

    @IBAction func photoButtonTapped(_ sender: Any) {
        if isUpdating {
            let alert = UIAlertController(title: "Update images", message: "As of now, if you would like to update your images, all images currently used will be discarded and only the new ones will be used.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let continueAction = UIAlertAction(title: "Continue", style: .default) { (action) in
                self.openPicker()
            }
            alert.addAction(cancelAction)
            alert.addAction(continueAction)
            present(alert, animated: true, completion: nil)
        } else {
            openPicker()
        }
    }
    
    func openPicker() {
        var config = YPImagePickerConfiguration()
        config.startOnScreen = .library
        config.colors.tintColor = Colors.TintColor
        config.colors.coverSelectorBorderColor = Colors.TintColor
        config.bottomMenuItemSelectedColour = Colors.TintColor
        config.library.maxNumberOfItems = 10
        config.library.mediaType = .photo
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { (items, cancelled) in
            self.images.removeAll()
            if cancelled {
                print("Picker was cancelled.")
            } else {
                for item in items {
                    switch item {
                    case .photo(let photo):
                        self.images.append(photo.image)
                    case .video(_):
                        break
                    }
                }
            }
            if self.images.count > 0 {
                self.imageSlideshow.setImageInputs(Utility.convertUIImageToImageSource(from: self.images))
            } else if !self.isUpdating {
                self.imageSlideshow.setImageInputs([ImageSource(image: UIImage.init(named: "placeholder")!)])
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @objc func didTapOnSlideshow() {
        imageSlideshow.presentFullScreenController(from: self)
    }
    
    func getDownloadLinks() {
        guard let listing = listing else {
            return
        }
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
}
