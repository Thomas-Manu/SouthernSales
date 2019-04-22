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
import MessageKit
import SDWebImage

class Utility {
    typealias Success = () -> Void
    typealias SuccessListing = (Listing?) -> Void
    typealias SuccessListings = ([Listing]?) -> Void
    typealias SuccessChannel = (Channel?) -> Void
    typealias SuccessChannels = ([Channel]) -> Void
    typealias SuccessMessage = (Message) -> Void
    typealias SuccessMessages = ([Message]) -> Void
    typealias Listener = (ListenerRegistration) -> Void
    typealias Change = (DocumentChange) -> Void
    typealias SuccessChange = (Listing, DocumentChangeType) -> Void
    typealias Failure = (Error) -> Void
    typealias Completion = () -> Void
    
    // MARK: - Firestore
    
    /**
     An initializer for all helper functions
     
     - returns: The current Firestore database
     */
    private static func initializeFirestoreDatabase() -> Firestore {
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        return db
    }
    
    /**
     Returns the current user that is logged in. If it returns a nil,
     user is still being initialized or not logged in.
     
     - returns: Current user
     */
    static func getCurrentUser() -> User? {
//        let handle = Auth.auth().addStateDidChangeListener { (auth, user) in
//            print("[Utility] \(user)")
//        }
//        
        guard let currentUser = Auth.auth().currentUser else {
            GIDSignIn.sharedInstance()?.signOut()
            return nil
        }
        
//        let group = DispatchGroup()
//        let manager = SDWebImageManager()
//        var photo = UIImage()
//        group.enter()
//        manager.loadImage(with: currentUser.photoURL, options: [], progress: { (recieved, expected, url) in
//            print("\(recieved)/\(expected)")
//        }) { (image, data, error, cacheType, finished, url) in
//            print("Finished? \(finished)")
//            if error == nil, let image = image {
//                photo = image
//            }
//            group.leave()
//        }
//
//        group.wait()
        return User(id: currentUser.uid,
                    name: currentUser.displayName!,
                    email: currentUser.email!,
                    reference: initializeFirestoreDatabase().collection("users").document(currentUser.uid))
    }
    
    static func getUserInformation(userID: String, success: @escaping (User) -> Void, failure: @escaping Failure) {
        let db = initializeFirestoreDatabase()
        db.collection("users").document(userID).getDocument { (snapshot, error) in
            if let error = error {
                failure(error)
            } else {
                guard let snapshot = snapshot, let data = snapshot.data() else {
                    failure(NSError(domain: "", code: 418, userInfo: [NSLocalizedDescriptionKey: "No data available."]))
                    return
                }
                success(User(id: userID,
                             name: data["name"] as! String,
                             email: data["email"] as! String,
                             reference: snapshot.reference))
            }
        }
    }
    
    static func databasePushRemoteTokenToUser() {
        let user = getCurrentUser()
        user?.reference.setData(["notificationToken": UserDefaults.standard.string(forKey: "RemoteToken")!], merge: true)
    }

    // MARK: Listing
    /**
     Uploads a new listing to Firestore database.

     - parameters:
         - listing: Listing to upload
         - failure: The failure closure in case an error occurs
    */
    static func databaseCreateListing(with listing: Listing, failure: @escaping (Error) -> Void) {
        databaseCreateListing(with: listing, failure: { (error) in
            failure(error)
        }, completion: nil)
    }
    
    /**
     Uploads a new listing to Firestore database.
     
     - parameters:
        - listing: Listing to upload
        - failure: The failure closure in case an error occurs
        - completion: The completion closure in case you need to know if it completed correctly.
    */
    static func databaseCreateListing(with listing: Listing, failure: @escaping Failure, completion: Completion?) {
        let db = initializeFirestoreDatabase()
        let user = getCurrentUser()
        let userRef = db.collection("users").document(user!.id)
        db.collection("listings").addDocument(data: [
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
            }
        }
    }

    /**
     Get all available listings with information.
     
     - parameters:
        - success: Success closure with an array of listings available
        - failure: The failure closure in case an error occurs
     */
    static func databaseReadListings(_ success: @escaping SuccessListings, _ failure: @escaping Failure) {
        let db = initializeFirestoreDatabase()
        var listings = [Listing]()
        
        db.collection("listings").order(by: "timestamp", descending: true).getDocuments { (snapshot, error) in
            if let err = error {
                failure(err)
                print("Error getting documents: \(err)")
            } else {
                guard let snapshot = snapshot else {
                    failure(NSError(domain: "", code: 418, userInfo: [NSLocalizedDescriptionKey: "No data available."]))
                    return
                }
                for document in snapshot.documents {
                    listings.append(parseListing(from: document))
                }
                success(listings)
            }
        }
    }
    
    /**
     Get information about a listing.
     
     - parameters:
        - reference: The reference to the listing document being looked up
         - success: Success closure with an the listing information
         - failure: The failure closure in case an error occurs
     */
    static func databaseReadListing(fromReference reference: DocumentReference, success: @escaping SuccessListing, failure: @escaping Failure) {
        reference.getDocument { (snapshot, error) in
            if let error = error {
                failure(error)
            } else {
                var listing = parseListing(from: snapshot!.data()!)
                listing.reference = snapshot?.reference
                success(listing)
            }
        }
    }
    
    /**
     Get all the listings that were made by the current user.
     
     - parameters:
         - success: Success closure with an array of listings available
         - failure: The failure closure in case an error occurs
     */
    static func databaseViewOwnedListings(_ listener: @escaping Listener, change: @escaping Change, failure: @escaping Failure) {
        let db = initializeFirestoreDatabase()
        let user = getCurrentUser()
        let userRef = db.collection("users").document(user!.id)
        let listen = db.collection("listings").whereField("user", isEqualTo: userRef).order(by: "timestamp", descending: true).addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                failure(error)
            } else {
                snapshot?.documentChanges.forEach({ (newChange) in
                    change(newChange)
                })
            }
        }
        listener(listen)
    }
    
    /**
     Update existing listing on Firestore database.
     
     - parameters:
         - listing: Updated listing
         - failure: The failure closure in case an error occurs
         - success: The success closure in case you need to know if it completed correctly
     */
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
    
    /**
     Remove a listing that exists.
     
     - parameters:
         - listing: The listing to remove
         - failure: The failure closure in case an error occurs
         - success: The success closure in case you need to know if it completed correctly
     */
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
    
    /**
     Remove a list of listings that exists.
     
     - parameters:
         - listings: The listings to remove
         - failure: The failure closure in case an error occurs
         - success: The success closure in case you need to know if it completed correctly
     */
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
                    failure(NSError(domain: "", code: 418, userInfo: [NSLocalizedDescriptionKey: "No data available."]))
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
                        if listings.count != 0 {
                            success(listings)
                        }
                    })
                } else {
                    success(nil)
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
        db.collection("channels").whereField("participants", arrayContains: user!.id).addSnapshotListener { (snapshot, error) in
            if let error = error {
                failure(error)
            } else {
                var channels = [Channel]()
                for document in snapshot!.documents {
                    let data = document.data()
                    channels.append(Channel(id: document.reference,
                                            participants: data["participants"] as! [String],
                                            listing: data["listing"] as! DocumentReference,
                                            title: data["title"] as! String,
                                            date: (data["latestDate"] as? Timestamp)?.dateValue() ?? Date.init()))
                }
                let group = DispatchGroup()
                var data = [Channel]()
                for var channel in channels {
                    for listingUser in channel.participants {
                        if listingUser != user!.id {
                            group.enter()
                            getUserInformation(userID: listingUser, success: { (user) in
                                channel.username = user.name
                                data.append(channel)
                                group.leave()
                            }, failure: { (error) in
                                failure(error)
                            })
                        }
                    }
                }
                
                group.notify(queue: .main, execute: {
                    success(data)
                })
            }
        }
//        db.collection("channels").whereField("participants", arrayContains: user!.id).getDocuments { (snapshot, error) in
//            if let error = error {
//                failure(error)
//            } else {
//                var channels = [Channel]()
//                for document in snapshot!.documents {
//                    let data = document.data()
//                    channels.append(Channel(id: document.reference,
//                                            participants: data["participants"] as! [String],
//                                            listing: data["listing"] as! DocumentReference,
//                                            title: data["title"] as! String,
//                                            date: (data["latestDate"] as? Timestamp)?.dateValue() ?? Date.init()))
//                }
//                let group = DispatchGroup()
//                var data = [Channel]()
//                for var channel in channels {
//                    for listingUser in channel.participants {
//                        if listingUser != user!.id {
//                            group.enter()
//                            getUserInformation(userID: listingUser, success: { (user) in
//                                channel.username = user.name
//                                data.append(channel)
//                                group.leave()
//                            }, failure: { (error) in
//                                failure(error)
//                            })
//                        }
//                    }
//                }
//
//                group.notify(queue: .main, execute: {
//                    success(data)
//                })
//            }
//        }
    }
    
    static func databaseReadChannel(fromReference reference: DocumentReference, success: @escaping SuccessChannel, failure: @escaping Failure) {
        reference.getDocument { (snapshot, error) in
            if let error = error {
                failure(error)
            } else {
                guard let snapshot = snapshot else {
                    failure(NSError(domain: "", code: 418, userInfo: [NSLocalizedDescriptionKey: "No data available."]))
                    return
                }
                success(parseChannel(from: snapshot.data()!, reference: reference))
            }
        }
    }
    
    static func databaseCreateChannel(fromListing listing: Listing, success: @escaping SuccessChannel, failure: @escaping Failure) {
        let db = initializeFirestoreDatabase()
        let user = getCurrentUser()
        let newChannel = db.collection("channels").addDocument(data: [
            "listing": listing.reference!,
            "participants": [user?.id, listing.user?.documentID],
            "title": listing.title,
            "previewImage": listing.imageRefs.first as Any
        ]) { (error) in
            if let error = error {
                failure(error)
            }
        }
        
        databaseReadChannel(fromReference: newChannel, success: { (channel) in
            if let channel = channel {
                success(channel)
            }
        }) { (error) in
            failure(error)
        }
    }
    
    static func databaseReadAllMessagesFromChannel(channel: Channel, listener: @escaping Listener, success: @escaping SuccessMessages, change: @escaping Change, failure: @escaping Failure) {
        let listen = channel.id?.collection("thread").order(by: "created", descending: true).addSnapshotListener({ (snapshot, error) in
            if let error = error {
                failure(error)
            } else {
                var messages = [Message]()
                guard let documents = snapshot?.documents else {
                    failure(NSError(domain: "", code: 418, userInfo: [NSLocalizedDescriptionKey: "No data available."]))
                    return
                }
                for document in documents {
                    messages.append(parseMessage(from: document.data(), withID: document.reference.documentID))
                }
                success(messages)
            }
            
            snapshot?.documentChanges.forEach({ (newChange) in
                change(newChange)
            })
        })
        listener(listen!)
    }
    
    static func databaseSendMessage(message: String, throughChannel channel: Channel, success: @escaping (Date) -> Void, failure: @escaping Failure) {
        guard let user = getCurrentUser() else {
            failure(NSError(domain: "", code: 418, userInfo: [NSLocalizedDescriptionKey: "No data available."]))
            return
        }
        let data: [String: Any] = [
            "kind": "text",
            "message": message,
            "senderID": user.id,
            "senderName": user.name,
            "created": Timestamp.init()
        ]
        channel.id?.collection("thread").addDocument(data: data, completion: { (error) in
            if let error = error {
                failure(error)
            } else {
                channel.id?.updateData(["latestDate": data["created"] as! Timestamp])
                success((data["created"] as! Timestamp).dateValue())
            }
        })
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
        var index = 0
        
        for image in images {
            asyncGroup.enter()
            let imageName = String(index) + randomString(length: 30) + ".jpg"
            let imageReference = userStorage.child(imageName)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            index += 1
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
        return Listing(title: data["title"] as! String,
                       price: data["price"] as! Double,
                       description: data["description"] as! String,
                       user: data["user"] as? DocumentReference,
                       imageRefs: data["images"] as? [String] ?? [],
                       created: (data["timestamp"] as! Timestamp).dateValue())
    }
    
    static func parseChannel(from data: [String: Any], reference: DocumentReference) -> Channel {
        var channel = Channel(id: reference,
                              participants: data["participants"] as! [String],
                              listing: data["listing"] as! DocumentReference,
                              title: data["title"] as! String,
                              date: (data["latestDate"] as? Timestamp)?.dateValue() ?? Date.init())
        if data["previewImage"] != nil {
            channel.previewImage = data["previewImage"] as? String
        }
        return channel
    }
    
    static func parseMessage(from data: [String: Any], withID id: String) -> Message {
        switch data["kind"] as! String {
        case "text":
            return Message(text: data["message"] as! String,
                           sender: Sender(id: data["senderID"] as! String, displayName: data["senderName"] as! String),
                           messageId: id,
                           date: (data["created"] as! Timestamp).dateValue())
        default:
            return Message(custom: data["message"] as! String,
                           sender: Sender(id: data["senderID"] as! String, displayName: data["senderName"] as! String),
                           messageId: id,
                           date: (data["created"] as! Timestamp).dateValue())
        }
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
