//
//  ListingsViewController.swift
//  
//
//  Created by Thomas Manu on 11/12/18.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import NVActivityIndicatorView

class ListingsViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, NVActivityIndicatorViewable {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    private let reuseIdentifier = "listingsCell"
    private let refreshControl = UIRefreshControl()
    var listingsData = [Listing]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.hostedDomain = "southern.edu"
        GIDSignIn.sharedInstance().signIn()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ListingsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(updateListings), for: .valueChanged)
        refreshControl.tintColor = UIColor(red:0.66, green:0.38, blue:0.98, alpha:1.0)
        
        searchBar.delegate = self
    }
    
    // MARK: - Firebase

    @objc fileprivate func updateListings() {
        if !refreshControl.isRefreshing {
            startAnimating(type: NVActivityIndicatorType.ballScaleRippleMultiple)
        }
        Utility.databaseReadListings({ (listing) in
            self.listingsData = listing
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
            self.stopAnimating()
        }) { (error) in
            self.refreshControl.endRefreshing()
            self.stopAnimating()
            
        }
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            stopAnimating()
        }
        else {
            updateListings()
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

// MARK: - Collection View
extension ListingsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listingsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ListingsCollectionViewCell
        let listing = listingsData[indexPath.row]
        cell.configure(title: listing.title, price: listing.price)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

// MARK: - Collection View Flow Layout
extension ListingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 2) - 30
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

// MARK: - Search Bar
extension ListingsViewController: UISearchBarDelegate, UISearchControllerDelegate {
    
}
