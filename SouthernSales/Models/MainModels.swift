//
//  MainModels.swift
//  SouthernSales
//
//  Created by Thomas Manu on 11/18/18.
//  Copyright © 2018 Thomas Manu. All rights reserved.
//

import UIKit

struct Listing {
    let id: String?
    let title: String
    let price: Double
    let description: String
    let user: String?
    //    let previewImage: UIImage
    //    let images: [UIImage]
    
    init(id: String? = nil, title: String, price: Double, description: String, user: String? = nil) {
        self.id = id
        self.title = title
        self.price = price
        self.description = description
        self.user = user
    }
}

struct User {
    let id: String
    let name: String
    let email: String
//    let profilePicture: UIImage
}
