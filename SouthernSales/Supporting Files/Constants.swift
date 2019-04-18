//
//  Constants.swift
//  SouthernSales
//
//  Created by Thomas Manu on 1/21/19.
//  Copyright © 2019 Thomas Manu. All rights reserved.
//

import UIKit

struct Constants {
    static let HomeToListingSegue = "homeToListingSegue"
    static let SavedToListingSegue = "savedToListingSegue"
    static let SettingsToLicensesSegue = "settingsToLicensesSegue"
    static let PreviewSegue = "previewSegue"
    static let SettingsToManageListingsSegue = "settingsToManageListingsSegue"
    
    static let replyAction = "replyAction"
    static let messageCategory = "messageCategory"
}

extension UIColor {
    static let backgroundColor = UIColor(red:0.93, green:0.90, blue:0.97, alpha:1.0)
    static let tintColor = UIColor(red:0.66, green:0.38, blue:0.98, alpha:1.0)
}

extension Notification.Name {
    static let didPostNewListing = Notification.Name("didPostNewListing")
}
