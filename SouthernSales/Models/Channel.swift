//
//  Channel.swift
//  SouthernSales
//
//  Created by Thomas Manu on 4/7/19.
//  Copyright © 2019 Thomas Manu. All rights reserved.
//

import UIKit
import FirebaseFirestore

struct Channel {
    let id: DocumentReference?
    let participants: [String]
    let listing: DocumentReference
    let title: String
    var latestDate: Date
    var username: String?
    var previewImage: String?
    
    init(id: DocumentReference? = nil, participants: [String], listing: DocumentReference, title: String, date: Date) {
        self.id = id
        self.participants = participants
        self.listing = listing
        self.title = title
        self.latestDate = date
    }
}
