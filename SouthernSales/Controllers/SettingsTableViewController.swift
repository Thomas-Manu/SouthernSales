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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return 5
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Photo"
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "About Me"
            } else {
                cell.textLabel?.text = "Notifications"
            }
        } else {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Help"
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
            
        } else {
            if indexPath.row == 4 {
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                    print("Error signing out: \(signOutError)")
                }
            }
        }
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
