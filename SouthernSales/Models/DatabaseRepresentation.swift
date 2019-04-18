//
//  DatabaseRepresentation.swift
//  SouthernSales
//
//  Created by Thomas Manu on 4/7/19.
//  Copyright © 2019 Thomas Manu. All rights reserved.
//

import UIKit
import FirebaseFirestore

protocol DatabaseRepresentation {
    var representation: [String: Any] { get }    
}

//extension Message: DatabaseRepresentation {
//    var representation: [String : Any] {
//        var rep: [String: Any] = [
//            "kind": kind,
//            "message": "",
//            "senderID": "",
//            "senderName": "",
//            "created": Timestamp.init()
//        ]
//        
//        return rep
//    }
//}

extension Listing: DatabaseRepresentation {
    var representation: [String : Any] {
        var rep: [String: Any] = [
            "title": title,
            "price": price,
            "description": descriptionString,
            "images": imageRefs,
            "timestamp": Timestamp(date: created)
        ]
        
        if let user = user {
            rep["user"] = user
        }
        
        return rep
    }
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
