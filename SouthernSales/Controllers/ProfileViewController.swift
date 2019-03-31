//
//  ProfileViewController.swift
//  SouthernSales
//
//  Created by Thomas Manu on 11/12/18.
//  Copyright © 2018 Thomas Manu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .black
        view.backgroundColor = Colors.BackgroundColor
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func backToProfile(segue: UIStoryboardSegue) {
        
    }

}
