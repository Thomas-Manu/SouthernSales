//
//  MainModels.swift
//  SouthernSales
//
//  Created by Thomas Manu on 11/18/18.
//  Copyright © 2018 Thomas Manu. All rights reserved.
//

import UIKit
import Firebase

struct Listing {
    var id: String?
    let title: String
    let price: Double
    let description: String
    let user: DocumentReference?
    //    let previewImage: UIImage
    let imageRefs: [String]
    var reference: DocumentReference?
    
    init(id: String? = nil, title: String, price: Double, description: String, user: DocumentReference? = nil, imageRefs: [String], reference: DocumentReference? = nil) {
        self.id = id
        self.title = title
        self.price = price
        self.description = description
        self.user = user
        self.imageRefs = imageRefs
        self.reference = reference
    }
}

struct User {
    let id: String
    let name: String
    let email: String
//    let profilePicture: UIImage
}
