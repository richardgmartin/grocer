//
//  OnlineUserTableViewController.swift
//  Grocer
//
//  Created by Richard Martin on 2016-11-05.
//  Copyright © 2016 richard martin. All rights reserved.
//

import UIKit
import Firebase

class OnlineUserTableViewController: UITableViewController {
    
    // MARK: properties
    var currentUsers: [String] = []
    let usersRef = FIRDatabase.database().reference(withPath: "online")
    let logoutButton = UIBarButtonItem()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // let logoutButton = UIBarButtonItem()
        logoutButton.title = "Logout"
        self.navigationItem.rightBarButtonItem = logoutButton
        
        usersRef.observe(.childAdded, with: { snap in
            guard let email = snap.value as? String else { return }
            self.currentUsers.append(email)
            let row = self.currentUsers.count - 1
            let indexPath = IndexPath(row: row, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .top)
        
        })
        
        usersRef.observe(.childRemoved, with: { snap in
            guard let emailToFind = snap.value as? String else { return }
            for (index, email) in self.currentUsers.enumerated() {
                if email == emailToFind {
                    let indexPath = IndexPath(row: index, section: 0)
                    self.currentUsers.remove(at: index)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        })
    }


    // MARK: - UITableView Delegate methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUsers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath)
        let onlineUserEmail = currentUsers[indexPath.row]
        cell.textLabel?.text = onlineUserEmail
        return cell
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        
        if sender == self.logoutButton {
            do {
                try! FIRAuth.auth()?.signOut()
                print("current user signed out")
            }
            dismiss(animated: true, completion: nil)
        }
    }
}
