//
//  User.swift
//  SouthernSales
//
//  Created by Thomas Manu on 11/18/18.
//  Copyright © 2018 Thomas Manu. All rights reserved.
//

import UIKit
import FirebaseFirestore

struct User {
    let id: String
    let name: String
    let email: String
    let reference: DocumentReference
//    let photo: UIImage?
}
