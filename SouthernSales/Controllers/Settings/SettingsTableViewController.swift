//
//  SettingsTableViewController.swift
//  SouthernSales
//
//  Created by Thomas Manu on 11/23/18.
//  Copyright © 2018 Thomas Manu. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = Colors.BackgroundColor
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if section == 1 {
            return 1
        } else {
            return 5
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Photo"
                cell.isUserInteractionEnabled = false
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "About Me"
                cell.isUserInteractionEnabled = false
            } else {
                cell.textLabel?.text = "Notifications"
                cell.isUserInteractionEnabled = false
            }
        }  else if indexPath.section == 1 {
            cell.textLabel?.text = "Manage Listings"
        } else {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Help"
                cell.isUserInteractionEnabled = false
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Terms & Conditions"
            } else if indexPath.row == 2 {
                cell.textLabel?.text = "Privacy Policy"
            } else if indexPath.row == 3 {
                cell.textLabel?.text = "Open Source Licenses"
            } else {
                cell.textLabel?.text = "Log Out"
                cell.accessoryType = .none
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Profile"
        } else {
            return "Support"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
        } else if indexPath.section == 1 {
            performSegue(withIdentifier: Constants.SettingsToManageListingsSegue, sender: nil)
        } else {
            if indexPath.row == 1 {
                performSegue(withIdentifier: Constants.SettingsToLicensesSegue, sender: 1)
            }
            if indexPath.row == 2 {
                performSegue(withIdentifier: Constants.SettingsToLicensesSegue, sender: 2)
            }
            if indexPath.row == 3 {
                performSegue(withIdentifier: Constants.SettingsToLicensesSegue, sender: 3)
            }
            if indexPath.row == 4 {
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                    present((storyboard?.instantiateViewController(withIdentifier: "signInVC"))!, animated: true, completion: nil)
                } catch let signOutError as NSError {
                    print("Error signing out: \(signOutError)")
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.SettingsToLicensesSegue {
            let vc = segue.destination as! MarkdownViewController
            switch (sender as! Int) {
            case 1:
                vc.title = "Terms & Conditions"
                vc.fileName = "terms-conditions"
            case 2:
                vc.title = "Privacy Policy"
                vc.fileName = "privacy-policy"
            case 3:
                vc.title = "Licenses"
                vc.fileName = "credits"
            default:
                return
            }
        }
    }
}
