//
//  OnboardingViewController.swift
//  SouthernSales
//
//  Created by Thomas Manu on 2/24/19.
//  Copyright © 2019 Thomas Manu. All rights reserved.
//

import UIKit
import paper_onboarding

class OnboardingViewController: UIViewController, PaperOnboardingDataSource, PaperOnboardingDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
//        print(onboarding)
        // Do any additional setup after loading the view.
        let onboarding = PaperOnboarding()
        onboarding.dataSource = self
        onboarding.delegate = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)
        
        // add constraints
        for attribute: NSLayoutConstraint.Attribute in [.left, .right, .top, .bottom] {
            let constraint = NSLayoutConstraint(item: onboarding,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: attribute,
                                                multiplier: 1,
                                                constant: 0)
            view.addConstraint(constraint)
        }
    }
    
    func onboardingItemsCount() -> Int {
        return 2
    }
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return [
            OnboardingItemInfo(informationImage: UIImage.init(named: "logo_noWords")!,
                               title: "Welcome to SouthernSales",
                               description: "SouthernSales is an intuitive app for students and made by students. We recognized that there has been a need for a marketplace just for us here at Southern Adventist University. Sure, Facebook Marketplace could work, but barely anyone uses it. So we created an app just for us here to be able to post and trade items such as books, clothes, and many other items.",
                               pageIcon: UIImage.init(named: "logo_noWords")!,
                               color: .white,
                               titleColor: .blue,
                               descriptionColor: .green,
                               titleFont: UIFont.systemFont(ofSize: 30),
                               descriptionFont: UIFont.systemFont(ofSize: 16)),
            
            OnboardingItemInfo(informationImage: UIImage.init(named: "placeholder")!,
                               title: "title",
                               description: "description",
                               pageIcon: UIImage.init(named: "placeholder")!,
                               color: .red,
                               titleColor: .blue,
                               descriptionColor: .green,
                               titleFont: UIFont.systemFont(ofSize: 22),
                               descriptionFont: UIFont.systemFont(ofSize: 16))
            ][index]
    }
    
    func onboardingWillTransitonToLeaving() {
        print("Done?")
        let initialController = self.storyboard?.instantiateViewController(withIdentifier: "initialView")
        self.present(initialController!, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
