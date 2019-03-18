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
        return 4
    }
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return [
            OnboardingItemInfo(informationImage: UIImage.init(named: "logo_noWords")!,
                               title: "Welcome to SouthernSales",
                               description: "SouthernSales is an intuitive app for students and made by students. Swipe to view what you can do with this app!",
                               pageIcon: UIImage.init(named: "logo_noWords")!,
                               color: .white,
                               titleColor: .darkGray,
                               descriptionColor: .darkGray,
                               titleFont: UIFont.systemFont(ofSize: 30),
                               descriptionFont: UIFont.systemFont(ofSize: 14)),
            
            OnboardingItemInfo(informationImage: UIImage.init(named: "placeholder")!,
                               title: "Post and View Advertisments",
                               description: "You can post your own ads for everyone to see. You can also just browse through all the ads that have been posted by fellow students.",
                               pageIcon: UIImage.init(named: "logo_noWords")!,
                               color: .white,
                               titleColor: .darkGray,
                               descriptionColor: .darkGray,
                               titleFont: UIFont.systemFont(ofSize: 22),
                               descriptionFont: UIFont.systemFont(ofSize: 14)),
            
            OnboardingItemInfo(informationImage: UIImage.init(named: "placeholder")!,
                               title: "Message Sellers",
                               description: "No need to go searching for phone numbers or emails! All you have to do when you find an ad you like is to just send a message to the seller in the same app.",
                               pageIcon: UIImage.init(named: "logo_noWords")!,
                               color: .white,
                               titleColor: .darkGray,
                               descriptionColor: .darkGray,
                               titleFont: UIFont.systemFont(ofSize: 22),
                               descriptionFont: UIFont.systemFont(ofSize: 14)),
            
            OnboardingItemInfo(informationImage: UIImage.init(named: "placeholder")!,
                               title: "Enjoy",
                               description: "We hope you use this app and share it with everyone else in this school! Swipe to move into the app.",
                               pageIcon: UIImage.init(named: "logo_noWords")!,
                               color: .white,
                               titleColor: .darkGray,
                               descriptionColor: .darkGray,
                               titleFont: UIFont.systemFont(ofSize: 22),
                               descriptionFont: UIFont.systemFont(ofSize: 14))
            ][index]
    }
    
    func onboardingWillTransitonToLeaving() {
        UserDefaults.standard.set(true, forKey: "oldTimer")
        print("User has finished intro!")
        let initialController = self.storyboard?.instantiateViewController(withIdentifier: "signInVC")
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
