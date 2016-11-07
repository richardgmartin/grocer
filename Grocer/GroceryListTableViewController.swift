//
//  GroceryListTableViewController.swift
//  Grocer
//
//  Created by Richard Martin on 2016-11-05.
//  Copyright © 2016 richard martin. All rights reserved.
//

import UIKit
import Firebase

class GroceryListTableViewController: UITableViewController {
    
    // MARK: Properties
    var items: [GroceryItem] = []
    var user: User!
    var userCountBarButtonItem: UIBarButtonItem!
    let ref = FIRDatabase.database().reference(withPath: "grocery-items")
    let userRef = FIRDatabase.database().reference(withPath: "online")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelectionDuringEditing = false
        
        userCountBarButtonItem = UIBarButtonItem(title: "1", style: .plain, target: self, action: #selector(userCountButtonDidTouch))
        userCountBarButtonItem.tintColor = UIColor.darkGray
        navigationItem.leftBarButtonItem = userCountBarButtonItem
                
        // MARK: Firebase Oberver
        // 1. order database (and tableview) by items completed -> .queryOrdered
        // 2. initiate firebase observer to monitor changes in database values -> .observe
        ref.queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
            var newItems: [GroceryItem] = []
            for item in snapshot.children {
                let groceryItem = GroceryItem(snapshot: item as! FIRDataSnapshot)
                newItems.append(groceryItem)
            }
            self.items = newItems
            self.tableView.reloadData()
            })
        
        // MARK: identify user
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            guard let user = user else { return }
            self.user = User(authData: user)
            
            // monitor online user status
            let currentUserRef = self.userRef.child(self.user.uid)
            currentUserRef.setValue(self.user.email)
            currentUserRef.onDisconnectRemoveValue()
        })
        
        // MARK: update user online count
        userRef.observe(.value, with: { snapshot in
            if snapshot.exists() {
                self.userCountBarButtonItem.title = snapshot.childrenCount.description
            } else {
                self.userCountBarButtonItem.title = "0"
            }
        })
    }

    // MARK: UITableView Delegate methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let groceryItem = items[indexPath.row]
        
        cell.textLabel?.text = groceryItem.name
        cell.detailTextLabel?.text = groceryItem.addedByUser
        
        toggleCellCheckbox(cell: cell, isCompleted: groceryItem.completed)

        return cell
    }

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            /* old static way to remove item from array inside app
            items.remove(at: indexPath.row)
            tableView.reloadData()
            */
            
            // MARK: Update Firebase -> Tableview Update
            // new dynamic way to remove item from firebase and update table view
            let groceryItem = items[indexPath.row]
            groceryItem.ref?.removeValue()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        var groceryItem = items[indexPath.row]
        let toggledCompletion = !groceryItem.completed
        
        toggleCellCheckbox(cell: cell, isCompleted: toggledCompletion)
        groceryItem.completed = toggledCompletion
        
        // alert firebase of change in completion state
        groceryItem.ref?.updateChildValues(["completed": toggledCompletion])
    }
    
    func toggleCellCheckbox( cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.black
        } else {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = UIColor.gray
            cell.detailTextLabel?.textColor = UIColor.gray
        }
    }
    
    @IBAction func addGroceryItem(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Grocery Item", message: "Add an Item", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField = alert.textFields?.first, let text = textField.text else { return }
            let groceryItem = GroceryItem(name: text, addedByUser: self.user.email, completed: false)
            let groceryItemRef = self.ref.child(text.lowercased())
            groceryItemRef.setValue(groceryItem.toAnyObject())
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }

    func userCountButtonDidTouch() {
        
        // back bar text
        let backBar = UIBarButtonItem()
        backBar.title = "Back"
        navigationController?.navigationBar.tintColor = .darkGray
        navigationItem.backBarButtonItem = backBar
        
        performSegue(withIdentifier: listToUsers, sender: nil)
    }
}
