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
    
    @IBAction func saveNewPost(_ sender: Any) {
        guard let title = titleText.text, let price = priceText.text, let description = descriptionView.text else {
            return
        }
        Utility.cloudStorageUploadImages(with: images, success: { (references) in
            let newPost = Listing.init(title: title, price: Double(price)!, description: description, imageRefs: references)
            Utility.databaseAddNewListing(with: newPost) { (error) in }
        }) { (error) in
            print("[PVC] \(error)")
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
            if cancelled {
                print("Picker was cancelled.")
            } else {
                self.images.removeAll()
                for item in items {
                    switch item {
                    case .photo(let photo):
                        self.images.append(photo.image)
                    case .video(_):
                        break
                    }
                }
            }
            self.imageSlideshow.setImageInputs(self.convertUIImageToImageSource(from: self.images))
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @objc func didTapOnSlideshow() {
        imageSlideshow.presentFullScreenController(from: self)
    }
}

extension PostViewController {
    func convertUIImageToImageSource(from images: [UIImage]) -> [ImageSource] {
        var array = [ImageSource]()
        for image in images {
            array.append(ImageSource(image: image))
        }
        return array
    }
}
