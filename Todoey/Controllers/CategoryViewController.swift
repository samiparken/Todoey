/* Organized by Commits */

// 1 - Apply UserDefaults.plist & Custom.plist
// 2 - CoreData
// 3 - Realm

// 4 - CocoaPod: SwiftCellKit


import UIKit
import RealmSwift
import SwipeCellKit

class CategoryViewController: UITableViewController {
    
    // Initialize Realm
    let realm = try! Realm()
    
    // Object Array
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Realm: Load Data
        loadCategories()
        
        tableView.rowHeight = 80.0
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // UIAlert
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)

        // UIAlert textField
        var textField = UITextField()
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField  //keep the data for action
        }
        
        // Triggered by clicking the "Add Item" button on our UIAlert.
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let newCategory = Category() //Realm Object
            newCategory.name = textField.text!
            
            self.save(category: newCategory)
        }
                
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1    // if categoryArray is nil, return 1
    }

    /* Called as many as the Number of Rows */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Cell Title
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categories added yet."
        
        //for SwipeCell
        cell.delegate = self
    
        return cell
    }

    // MARK: - TableView Delegate Methods
    
    /* for Interaction with TableView */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    

    
    //MARK: - Data Manipulation Methods
    //CoreData CRUD (Create/Read/Update/Delete)
    
    // Save Data into CoreData
    func save(category: Category) {
        do {
            try realm.write { // Make Realm updated
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        tableView.reloadData()
    }

    // Load Data from Realm
    func loadCategories() {
        
        categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()
        
    }
}

//MARK: - SwipeCell Delegate Methods
extension CategoryViewController: SwipeTableViewCellDelegate {

    // SwipeCell Animation Kit
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            // Realm: Delete
            if let category = self.categoryArray?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(category)  // delete
                        print("Category Deleted")
                    }
                } catch {
                    print("Error saving done status, \(error)")
                }
            }
//            self.tableView.reloadData()    // comment for .destructive swipe action
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction]
    }
    
    // Customize the behavior of the swipe actions
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
//        options.transitionStyle = .border
        return options
    }
    
    
}
