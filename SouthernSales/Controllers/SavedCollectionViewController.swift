//
//  SavedCollectionViewController.swift
//  SouthernSales
//
//  Created by Thomas Manu on 11/12/18.
//  Copyright © 2018 Thomas Manu. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import FirebaseStorage
import FirebaseUI

private let reuseIdentifier = "listingsCell"

class SavedCollectionViewController: UICollectionViewController, NVActivityIndicatorViewable {
    
    private let refreshControl = UIRefreshControl()
    var listingsData = [Listing]()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "ListingsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .backgroundColor
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(updateListings), for: .valueChanged)
        refreshControl.tintColor = .tintColor
        navigationController?.navigationBar.barStyle = .black
        updateListings()
    }
    
    @objc func updateListings() {
        if !refreshControl.isRefreshing {
            startAnimating(type: NVActivityIndicatorType.ballScaleRippleMultiple)
        }
        Utility.databaseReadFavorites({ (favs) in
            if let favs = favs {
                self.listingsData = favs
                self.collectionView.reloadData()
            }
            self.stopAnimating()
            self.refreshControl.endRefreshing()
        }) { (error) in
            print("[SCVC] Failed to get favorites with error: \(error)")
            self.stopAnimating()
            self.refreshControl.endRefreshing()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == Constants.SavedToListingSegue {
            let vlvc = segue.destination as! ViewListingViewController
            let listing = sender as! Listing
            vlvc.title = listing.title
            vlvc.listing = listing
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listingsData.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ListingsCollectionViewCell
        let listing = listingsData[indexPath.row]
        cell.configure(title: listing.title, price: listing.dollarFormat())
        
        let userImageRef = Storage.storage().reference(withPath: "images/\(listing.user!.documentID)")
        let previewImageRef = userImageRef.child("/\(listing.imageRefs[0])")
        cell.previewImageView.sd_setImage(with: previewImageRef, placeholderImage: UIImage.init(named: "placeholder"))
        
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.SavedToListingSegue, sender: listingsData[indexPath.row])
    }

}

// MARK: - Collection View Flow Layout
extension SavedCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 2) - 30
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
