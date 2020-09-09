//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()    // Array of Objects
    
    // User Default (UserDefaults.plist)   // Only key-value pairs
    //let defaults = UserDefaults.standard
    
    // Data (custom.plist)
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //print(dataFilePath!)  //show dataFilePath (Item.plist)
        
        // Load Data from custom.plist
        loadItems()
        
        // Recover Saved Local Data from User Default (UserDefaults.plist)
//        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
//            itemArray = items
//        }

    }
    
    //MARK: - TableView Datasource Methods
    
    /* Return How many Rows */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    /* Called as many as the Number of Rows */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Cell Title
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        // Cell Check/UnCheck
        cell.accessoryType = item.Done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    /* for Interaction with TableView */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Check <-> UnCheck applied on Item
        itemArray[indexPath.row].Done = !itemArray[indexPath.row].Done
                    
        //Selection Animated Effect
        tableView.deselectRow(at: indexPath, animated: true)
        
        saveItems() //Save Data
        self.tableView.reloadData() //Renew tableView Data
    }
    
    //MARK: - Add New Items (UIAlert)
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // UIAlert
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)

        // UIAlert textField
        var textField = UITextField()
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField  //keep the data for action
        }
        
        // Triggered by clicking the "Add Item" button on our UIAlert.
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let newItem = Item()
            newItem.title = textField.text!
            self.itemArray.append(newItem)
            
            self.saveItems()

            //self.defaults.set(self.itemArray, forKey: "TodoListArray") // Save itemArray as UserDefaults
            self.tableView.reloadData() //Renew tableView Data
        }
                
        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }

    
    //MARK: - Model Manupulation Methods
    //NSCoder for encoding & decoding
    
    // Save Data into custom.plist
    func saveItems() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(self.itemArray)
            try data.write(to: self.dataFilePath!)
        } catch {
            print("Error encoding item array, \(error)")
        }
    }

    // Load Data from custom.plist
    func loadItems()
    {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding item array, \(error)")
            }
        }
    }


}
