//
//  Listing.swift
//  SouthernSales
//
//  Created by Thomas Manu on 2/18/19.
//  Copyright © 2019 Thomas Manu. All rights reserved.
//

import UIKit
import Firebase

class Listing: NSObject {
    let title: String
    let price: Double
    let descriptionString: String
    let user: DocumentReference?
    //    let previewImage: UIImage
    let imageRefs: [String]
    var reference: DocumentReference?
    var saved: Bool
    
    init(title: String, price: Double, description: String, user: DocumentReference? = nil, imageRefs: [String], reference: DocumentReference? = nil, saved: Bool = false) {
        self.title = title
        self.price = price
        self.descriptionString = description
        self.user = user
        self.imageRefs = imageRefs
        self.reference = reference
        self.saved = saved
    }
}
