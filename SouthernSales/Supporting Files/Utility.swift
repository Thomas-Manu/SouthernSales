//
//  Utility.swift
//  SouthernSales
//
//  Created by Thomas Manu on 11/18/18.
//  Copyright © 2018 Thomas Manu. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage


class Utility {
    // MARK: - Firestore
    
    /**
     An initializer for all helper functions
     
     Returns: The current Firestore database
     */
    private static func initializeFirestoreDatabase() -> Firestore {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        return db
    }
    
    private static func getCurrentUser() -> User? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        return User.init(id: currentUser.uid, name: currentUser.displayName!, email: currentUser.email!)
    }

    static func databaseAddNewListing(with listing: Listing, failure: @escaping (Error) -> Void) {
        let db = initializeFirestoreDatabase()
        let user = getCurrentUser()
        let userRef = db.collection("users").document(user!.id)
        var ref: DocumentReference? = nil
        ref = db.collection("listings").addDocument(data: [
            "title": listing.title,
            "price": listing.price,
            "description": listing.descriptionString,
            "timestamp": Timestamp.init(),
            "user": userRef
            ]) { error in
            if let err = error {
                failure(err)
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }

    static func databaseReadListings(_ success: @escaping ([Listing]) -> Void, _ failure: @escaping (Error) -> Void) {
        let db = initializeFirestoreDatabase()
        var listings = [Listing]()
        db.collection("listings").getDocuments { (snapshot, error) in
            if let err = error {
                failure(err)
                print("Error getting documents: \(err)")
            } else {
                for document in snapshot!.documents {
                    listings.append(parseListing(from: document))
                }
                success(listings)
            }
        }
    }
    
//    static func databaseReadListing(with listingRef: DocumentReference, _ success: @escaping (Listing) -> Void, _ failure: @escaping (Error) -> Void) {
//        let db = initializeFirestoreDatabase()
//
//    }
    
    static func databaseReadFavorites(_ success: @escaping ([Listing]) -> Void, _ failure: @escaping (Error) -> Void) {
        let db = initializeFirestoreDatabase()
        guard let user = getCurrentUser() else {
            failure(NSError(domain: "", code: 404, userInfo: ["description": "User not found or initialized"]))
            return
        }
        let userRef = db.collection("users").document(user.id)
        
        userRef.getDocument(completion: { (snapshot, error) in
            if let err = error {
                failure(err)
                print("Error getting document: \(err)")
            } else {
                if let documentRefs = snapshot?.data()!["favorites"] as? [DocumentReference] {
                    var listings = [Listing]()
                    let asyncGroup = DispatchGroup()
                    for refs in documentRefs {
                        asyncGroup.enter()
                        refs.getDocument(completion: { (snapshot, error) in
                            if let err = error {
                                failure(err)
                                print("Error getting document: \(err)")
                            } else {
                                var listing = parseListing(from: (snapshot?.data())!)
                                listing.reference = refs
                                listing.saved = true
                                listings.append(listing)
                            }
                            asyncGroup.leave()
                        })
                    }
                    asyncGroup.notify(queue: .main, execute: {
                        success(listings)
                    })
                }
            }
        })
    }
    
    static func databaseAddNewFavorite(with listing: Listing, success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        let db = initializeFirestoreDatabase()
        let user = getCurrentUser()
        let userRef = db.collection("users").document(user!.id)
        userRef.setData(["favorites": FieldValue.arrayUnion([listing.reference as Any])], merge: true) { (error) in
            if let error = error {
                failure(error)
            }
            else {
                success()
            }
        }
    }
    
    static func databaseRemoveFavorite(with listing: Listing, success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        let db = initializeFirestoreDatabase()
        let user = getCurrentUser()
        let userRef = db.collection("users").document(user!.id)
        userRef.updateData(["favorites" : FieldValue.arrayRemove([listing.reference as Any])]) { (error) in
            if let error = error {
                failure(error)
            }
            else {
                success()
            }
        }
    }
    

    static func cloudStorageGetImageURLs(from listing: Listing, success: @escaping ([URL]) -> Void, failure: @escaping (Error) -> Void) {
        var urls = [URL]()
        let userImageRef = Storage.storage().reference(withPath: "images/\(listing.user!.documentID)")
        let asyncGroup = DispatchGroup()
        
        for imageRefs in listing.imageRefs {
            asyncGroup.enter()
            let reference = userImageRef.child("/\(imageRefs)")
            reference.downloadURL { (url, error) in
                if let error = error {
                    failure(error)
                    print("Error getting URL: \(error)")
                } else {
                    urls.append(url!)
                }
                asyncGroup.leave()
            }
        }
        asyncGroup.notify(queue: .main) {
            success(urls)
        }
    }
}

extension Utility {
    static func parseListing(from document: QueryDocumentSnapshot) -> Listing {
        let listing = parseListing(from: document.data())
        listing.reference = document.reference
        return listing
    }
    
    static func parseListing(from data: [String: Any]) -> Listing {
        return Listing.init(title: data["title"] as! String,
                            price: data["price"] as! Double,
                            description: data["description"] as! String,
                            user: data["user"] as? DocumentReference,
                            imageRefs: data["images"] as! [String])
    }
    
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...length-1).map{ _ in letters.randomElement()! })
    }
}
