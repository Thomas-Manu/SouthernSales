//
//  SplashViewController.swift
//  SouthernSales
//
//  Created by Thomas Manu on 12/17/18.
//  Copyright © 2018 Thomas Manu. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstImageView.alpha = 1
        secondImageView.alpha = 0
        self.view.bringSubviewToFront(firstImageView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.75, animations: {
            self.firstImageView.alpha = 0
        }) { (finished) in
            self.firstImageView.removeFromSuperview()
            UIView.animate(withDuration: 0.75, animations: {
                self.secondImageView.alpha = 1
            }) { (complete) in
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    self.performSegue(withIdentifier: "onboardingSegue", sender: nil)
//                    let initialController = self.storyboard?.instantiateViewController(withIdentifier: "initialView")
//                    self.present(initialController!, animated: false, completion: nil)
                })
            }
        }
    }
}
