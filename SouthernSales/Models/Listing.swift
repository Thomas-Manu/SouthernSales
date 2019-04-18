//
//  Listing.swift
//  SouthernSales
//
//  Created by Thomas Manu on 2/18/19.
//  Copyright © 2019 Thomas Manu. All rights reserved.
//

import UIKit
import Firebase

struct Listing {
    let title: String
    let price: Double
    let descriptionString: String
    let user: DocumentReference?
    //    let previewImage: UIImage
    var imageRefs: [String]
    var reference: DocumentReference?
    var saved: Bool
    var created: Date
    
    init(title: String, price: Double, description: String, user: DocumentReference? = nil, imageRefs: [String], reference: DocumentReference? = nil, saved: Bool = false, created: Date) {
        self.title = title
        self.price = price
        self.descriptionString = description
        self.user = user
        self.imageRefs = imageRefs
        self.reference = reference
        self.saved = saved
        self.created = created
    }
    
    func dollarFormat() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let finalAmount = formatter.string(from: price as NSNumber) {
            return finalAmount
        } else {
            return "$\(price)"
        }
    }
}

extension Listing: Equatable {
    static func == (lhs: Listing, rhs: Listing) -> Bool {
        return
            lhs.title == rhs.title &&
            lhs.price == rhs.price &&
            lhs.descriptionString == rhs.descriptionString &&
            lhs.user == rhs.user &&
            lhs.imageRefs == rhs.imageRefs &&
            lhs.reference == rhs.reference &&
            lhs.created == rhs.created
    }
}
