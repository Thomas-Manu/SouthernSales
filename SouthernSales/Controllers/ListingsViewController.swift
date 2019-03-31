//
//  ListingsViewController.swift
//  SouthernSales
//
//  Created by Thomas Manu on 11/12/18.
//  Copyright © 2018 Thomas Manu. All rights reserved.
//

import UIKit
//import GoogleSignIn
import FirebaseAuth
import NVActivityIndicatorView
import FirebaseStorage
import FirebaseUI

class ListingsViewController: UIViewController, /*GIDSignInDelegate, GIDSignInUIDelegate,*/ NVActivityIndicatorViewable {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    private let reuseIdentifier = "listingsCell"
    private let refreshControl = UIRefreshControl()
    var listingsData = [Listing]()
    var searchData = [Listing]()
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        GIDSignIn.sharedInstance()?.uiDelegate = self
//        GIDSignIn.sharedInstance()?.delegate = self
//        GIDSignIn.sharedInstance()?.signIn()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ListingsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = Colors.BackgroundColor
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(updateListings), for: .valueChanged)
        refreshControl.tintColor = Colors.TintColor
        
        navigationController?.navigationBar.barStyle = .black
        
        searchBar.delegate = self
        searchBar.tintColor = .white
        searchBar.returnKeyType = .done
        UITextField.appearance(whenContainedInInstancesOf: [type(of: searchBar)]).tintColor = .black
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.singleTap(sender:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(singleTapGestureRecognizer)
        isSearching = false
        
        updateListings()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == Constants.HomeToListingSegue {
            let vlvc = segue.destination as! ViewListingViewController
            let listing = sender as! Listing
            vlvc.title = listing.title
            vlvc.listing = listing
        }
    }
}

// MARK: - Firebase
extension ListingsViewController {
    @objc fileprivate func updateListings() {
        if !refreshControl.isRefreshing {
            startAnimating(type: NVActivityIndicatorType.ballScaleRippleMultiple)
        }
        Utility.databaseReadListings({ (listings) in
            Utility.databaseReadFavorites({ (favs) in
                var data = [Listing]()
                for listing in self.listingsData {
                    let temp = listing
                    temp.saved = favs.contains(where: { $0.reference?.documentID == listing.reference?.documentID  })
                    data.append(temp)
                }
                self.listingsData = data
            }) { (error) in
                print("[LVC] Failed to get favorites")
            }
            self.listingsData = listings
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
            self.stopAnimating()
        }) { (error) in
            self.refreshControl.endRefreshing()
            self.stopAnimating()
        }
    }
    
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        if error != nil {
//            stopAnimating()
//        }
//        else {
//            //            Auth.auth().addStateDidChangeListener { (auth, user) in
//            //                if user != nil {
//            //                    self.updateListings()
//            //                } else {
//            ////                    signIn.signIn()
//            //                }
//            //            }
//            updateListings()
//        }
//    }
    
//    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
//        present(viewController, animated: true, completion: nil)
//    }
//
//    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
//        print("Bleh")
//    }
}

// MARK: - Collection View
extension ListingsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? searchData.count : listingsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ListingsCollectionViewCell
        let listing = isSearching ? searchData[indexPath.row] : listingsData[indexPath.row]
        cell.configure(title: listing.title, price: listing.price)
        
        if listing.imageRefs.count > 0 {
            let userImageRef = Storage.storage().reference(withPath: "images/\(listing.user!.documentID)")
            let previewImageRef = userImageRef.child("/\(listing.imageRefs[0])")
            cell.previewImageView.sd_setImage(with: previewImageRef, placeholderImage: UIImage.init(named: "placeholder"))
        } else {
            cell.previewImageView.image = UIImage.init(named: "placeholder")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.HomeToListingSegue, sender: isSearching ? searchData[indexPath.row] : listingsData[indexPath.row])
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
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

// MARK: - Search Bar
extension ListingsViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
        searchData = listingsData
        searchBar.showsCancelButton = true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            searchData = listingsData.filter({ (listing) -> Bool in
                listing.title.localizedCaseInsensitiveContains(searchText)
            })
        } else {
            searchData = listingsData
        }
        print("Search: \(searchText) count: \(searchData.count)")
        collectionView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Cancel button")
        isSearching = false
        searchBar.showsCancelButton = false
        searchBar.text = nil
        collectionView.reloadData()
    }

    @objc func singleTap(sender: UITapGestureRecognizer) {
        self.searchBar.resignFirstResponder()
    }
}
