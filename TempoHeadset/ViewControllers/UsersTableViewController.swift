//
//  UsersTableViewController.swift
//  TempoHeadset
//
//  Created by Soltis, Matthew on 2/5/19.
//  Copyright © 2019 Soltis, Matthew. All rights reserved.
//

import UIKit

class UsersTableViewController: UITableViewController {
    var users = [String]()
    
    override func viewDidLoad() {
        print("users ViewDidLoad")
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.clear
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "datacell", for: indexPath)
        
        // Configure the cell...
        cell.textLabel?.text = users[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    func modifyUsers(newUsers: [String]) {
        users = newUsers
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var suffix = "people"
        switch (section) {
        case 0:
            if users.count == 1 {
                suffix = "person"
            }
            return ("Users on my channel: (\(users.count) " + suffix + ")")
        default:
            return ("Something went wrong")
        }
    }
}

