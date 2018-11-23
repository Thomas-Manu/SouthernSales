//
//  ListingsCollectionViewCell.swift
//  SouthernSales
//
//  Created by Thomas Manu on 11/18/18.
//  Copyright © 2018 Thomas Manu. All rights reserved.
//

import UIKit

class ListingsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.blue
    }
    
    func configure(title: String, price: NSNumber) {
//        previewImageView?.image = previewImage
        titleLabel?.text = title
        priceLabel?.text = "$\(price)"
    }

}
