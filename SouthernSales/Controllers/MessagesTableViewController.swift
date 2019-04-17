//
//  MessagesTableViewController.swift
//  SouthernSales
//
//  Created by Thomas Manu on 11/12/18.
//  Copyright © 2018 Thomas Manu. All rights reserved.
//

import UIKit

class MessagesTableViewController: UITableViewController {
    
    var channels = [Channel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .black
        tableView.backgroundColor = Colors.BackgroundColor
        pullData()

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messagesCell", for: indexPath) as! MessageTableViewCell
        let channel = channels[indexPath.row]
        
        cell.titleLabel.text = channel.title
        cell.usernameLabel.text = channel.username
        cell.dateLabel.text = channel.latestDate.formatRelativeString()

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
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "messageSegue", sender: indexPath.row)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ChatViewController
        vc.channel = channels[sender as! Int]
    }

}

extension MessagesTableViewController {
    func pullData() {
        Utility.databaseReadChannels({ (channels) in
            self.channels = channels
            self.channels.sort { (lhs, rhs) -> Bool in
                return lhs.latestDate > rhs.latestDate
            }
            self.tableView.reloadData()
        }) { (error) in
            print("[MTVC] Error: \(error)")
        }
    }
}

// https://stackoverflow.com/a/48652058
extension Date {
    func formatRelativeString() -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar(identifier: .gregorian)
        dateFormatter.doesRelativeDateFormatting = true
        
        if calendar.isDateInToday(self) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
        } else if calendar.isDateInYesterday(self){
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .medium
        } else if calendar.compare(Date(), to: self, toGranularity: .weekOfYear) == .orderedSame {
            let weekday = calendar.dateComponents([.weekday], from: self).weekday ?? 0
            return dateFormatter.weekdaySymbols[weekday-1]
        } else {
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .short
        }
        
        return dateFormatter.string(from: self)
    }
}
