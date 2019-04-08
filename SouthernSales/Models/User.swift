//
//  User.swift
//  SouthernSales
//
//  Created by Thomas Manu on 11/18/18.
//  Copyright © 2018 Thomas Manu. All rights reserved.
//

import UIKit
//import FirebaseFirestore

struct User {
    let id: String
    let name: String
    let email: String
//    let profilePicture: UIImage
}

extension User: DatabaseRepresentation {
    var representation: [String : Any] {
        let rep: [String: Any] = [
            "id": id,
            "name": name,
            "email": email
        ]
        
        return rep
    }
}
