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
        var ref: DocumentReference? = nil
        ref = db.collection("listings").addDocument(data: [
            "title": listing.title,
            "price": listing.price,
            "description": listing.description,
            "timestamp": Timestamp.init(),
            "user": "/users/\(user!.id)" 
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
                    listings.append(Listing.init(id: document.documentID,
                                                 title: document.data()["title"] as! String,
                                                 price: document.data()["price"] as! Double,
                                                 description: document.data()["description"] as! String,
                                                 user: document.data()["user"] as? String))
                }
                success(listings)
            }
        }
    }
}
