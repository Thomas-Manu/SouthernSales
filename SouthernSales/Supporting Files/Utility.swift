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
import GoogleSignIn
import ImageSlideshow

class Utility {
    typealias Success = () -> Void
    typealias SuccessListing = (Listing?) -> Void
    typealias SuccessListings = ([Listing]?) -> Void
    typealias SuccessChannel = (Channel?) -> Void
    typealias SuccessChannels = ([Channel]) -> Void
    typealias SuccessMessage = (Message) -> Void
    typealias SuccessMessages = ([Message]) -> Void
    typealias Failure = (Error) -> Void
    typealias Completion = () -> Void
    
    // MARK: - Firestore
    
    /**
     An initializer for all helper functions
     
     Returns: The current Firestore database
     */
    private static func initializeFirestoreDatabase() -> Firestore {
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        return db
    }
    
    static func getCurrentUser() -> User? {
        guard let currentUser = Auth.auth().currentUser else {
            GIDSignIn.sharedInstance()?.signOut()
            return nil
        }
        return User.init(id: currentUser.uid, name: currentUser.displayName!, email: currentUser.email!)
    }

    // MARK: Listing
    static func databaseAddNewListing(with listing: Listing, failure: @escaping (Error) -> Void) {
        databaseAddNewListing(with: listing, failure: { (error) in
            failure(error)
        }, completion: nil)
    }
    
    static func databaseAddNewListing(with listing: Listing, failure: @escaping Failure, completion: Completion?) {
        let db = initializeFirestoreDatabase()
        let user = getCurrentUser()
        let userRef = db.collection("users").document(user!.id)
        var ref: DocumentReference? = nil
        ref = db.collection("listings").addDocument(data: [
            "title": listing.title,
            "price": listing.price,
            "description": listing.descriptionString,
            "timestamp": Timestamp.init(),
            "user": userRef,
            "images": listing.imageRefs
        ]) { error in
            if let err = error {
                failure(err)
                print("Error adding document: \(err)")
            } else {
                completion?()
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }

    static func databaseReadListings(_ success: @escaping SuccessListings, _ failure: @escaping Failure) {
        let db = initializeFirestoreDatabase()
        var listings = [Listing]()
        db.collection("listings").order(by: "timestamp", descending: true).getDocuments { (snapshot, error) in
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
        
        db.collection("listings").order(by: "timestamp", descending: true).addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                return
            }
            
            snapshot.documentChanges.forEach({ (change) in
                switch (change.type) {
                case .added:
                    print("[Utility] Document added \(change.document.data())")
                case .modified:
                    print("[Utility] Document modified \(change.document.data())")
                case .removed:
                    print("[Utility] Document removed \(change.document.data())")
                }
            })
        }
    }
    
    static func databaseViewOwnedListings(_ success: @escaping SuccessListings, _ failure: @escaping Failure) {
        let db = initializeFirestoreDatabase()
        let user = getCurrentUser()
        let userRef = db.collection("users").document(user!.id)
        var listings = [Listing]()
        db.collection("listings").whereField("user", isEqualTo: userRef).order(by: "timestamp", descending: true).getDocuments { (snapshot, error) in
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
    
    static func databaseUpdateListing(_ listing: Listing, success: @escaping Success, failure: @escaping Failure) {
        listing.reference?.updateData([
            "title": listing.title,
            "price": listing.price,
            "description": listing.descriptionString,
            "images": listing.imageRefs
            ], completion: { (error) in
                if let error = error {
                    failure(error)
                } else {
                    success()
                }
        })
    }
    
    static func databaseRemoveListing(_ listing: Listing, success: @escaping Success, failure: @escaping Failure) {
        listing.reference?.delete(completion: { (error) in
            if let error = error {
                failure(error)
            } else {
                success()
                print("Document successfully removed!")
            }
        })
    }
    
    static func databaseRemoveListings(_ listings: [Listing], success: @escaping Success, failure: @escaping Failure) {
        for listing in listings {
            Utility.databaseRemoveListing(listing, success: {
                success()
            }) { (error) in
                failure(error)
            }
        }
    }
    
    // MARK: Favorites
    static func databaseReadFavorites(_ success: @escaping SuccessListings, _ failure: @escaping Failure) {
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
                guard let data = snapshot?.data() else {
                    success(nil)
                    return
                }
                if let documentRefs = data["favorites"] as? [DocumentReference] {
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
    
    static func databaseAddNewFavorite(with listing: Listing, success: @escaping Success, failure: @escaping Failure) {
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
    
    static func databaseRemoveFavorite(with listing: Listing, success: @escaping Success, failure: @escaping Failure) {
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
    
    // MARK: Messaging
    static func databaseReadChannels(_ success: @escaping SuccessChannels, failure: @escaping Failure) {
        let db = initializeFirestoreDatabase()
        let user = getCurrentUser()
        db.collection("channels").whereField("participants", arrayContains: user!.id).getDocuments { (snapshot, error) in
            if let error = error {
                failure(error)
            } else {
                var channels = [Channel]()
                for document in snapshot!.documents {
                    channels.append(Channel(id: document.reference, participants: document.data()["participants"] as! [String], listing: document.data()["listing"] as! DocumentReference))
                }
                success(channels)
            }
        }
    }

    // MARK: Cloud Storage
    static func cloudStorageGetImageURLs(from listing: Listing, success: @escaping ([URL]) -> Void, failure: @escaping Failure) {
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
    
    static func cloudStorageUploadImages(with images: [UIImage], success: @escaping ([String]) -> Void, failure: @escaping Failure) {
        let user = getCurrentUser()
        let userStorage = Storage.storage().reference(withPath: "images/\(user!.id)")
        let asyncGroup = DispatchGroup()
        var imageNameList = [String]()
        
        for image in images {
            asyncGroup.enter()
            let imageName = randomString(length: 30) + ".jpg"
            let imageReference = userStorage.child(imageName)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            imageReference.putData(image.jpegData(compressionQuality: 0.5)!, metadata: metadata) { (metadata, error) in
                if error != nil {
                    failure(error!)
                } else {
                    imageNameList.append(imageName)
                }
                asyncGroup.leave()
            }
        }
        
        asyncGroup.notify(queue: .main) {
            success(imageNameList)
        }
    }
}

extension Utility {
    static func parseListing(from document: QueryDocumentSnapshot) -> Listing {
        var listing = parseListing(from: document.data())
        listing.reference = document.reference
        return listing
    }
    
    static func parseListing(from data: [String: Any]) -> Listing {
        return Listing.init(title: data["title"] as! String,
                            price: data["price"] as! Double,
                            description: data["description"] as! String,
                            user: data["user"] as? DocumentReference,
                            imageRefs: data["images"] as? [String] ?? [])
    }
    
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...length-1).map{ _ in letters.randomElement()! })
    }
    
    static func convertUIImageToImageSource(from images: [UIImage]) -> [ImageSource] {
        var array = [ImageSource]()
        for image in images {
            array.append(ImageSource(image: image))
        }
        return array
    }
    
    static func alertWith(_ title: String, message: String, actions: [UIAlertAction]) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alert.addAction(action)
        }
        return alert
    }
}
