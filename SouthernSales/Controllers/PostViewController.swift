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
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.BackgroundColor
        navigationController?.navigationBar.barStyle = .black
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnSlideshow))
        imageSlideshow.addGestureRecognizer(gestureRecognizer)
        imageSlideshow.setImageInputs([ImageSource(image: UIImage.init(named: "placeholder")!)])
        imageSlideshow.backgroundColor = Colors.BackgroundColor
    }
    
    @IBAction func resetPost(_ sender: Any) {
        titleText.text = ""
        priceText.text = ""
        descriptionView.text = ""
        images.removeAll()
        imageSlideshow.setImageInputs([ImageSource(image: UIImage.init(named: "placeholder")!)])
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
        openPicker()
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
            } else {
                self.imageSlideshow.setImageInputs([ImageSource(image: UIImage.init(named: "placeholder")!)])
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @objc func didTapOnSlideshow() {
        imageSlideshow.presentFullScreenController(from: self)
    }
}
