//
//  ManageListingsTableViewController.swift
//  SouthernSales
//
//  Created by Thomas Manu on 4/2/19.
//  Copyright © 2019 Thomas Manu. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ManageListingsTableViewController: UITableViewController, NVActivityIndicatorViewable {

    var listingsData = [Listing]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
        title = "Manage Listings"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        startAnimating(type: NVActivityIndicatorType.ballScaleRippleMultiple)
        Utility.databaseViewOwnedListings({ (listings) in
            self.listingsData = listings
            self.tableView.reloadData()
            self.stopAnimating()
        }) { (error) in
            print("[MLTVC] Error: \(error)")
            self.stopAnimating()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listingsData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listingCell", for: indexPath)
        let listing = listingsData[indexPath.row]
        cell.textLabel?.text = listing.title

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Utility.databaseRemoveListing(listingsData[indexPath.row], success: {
                self.listingsData.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }) { (error) in
                print("[MLTVC] Error: \(error)")
            }
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
