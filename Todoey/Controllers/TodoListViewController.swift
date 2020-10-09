
import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    // Prep for Segue
    var selectedCategory: Category? {
        didSet{ //Trigger when the value is set
            loadItems()
        }
    }

    // Object Array
    var itemArray = [Item]()
    
    // For CoreData (Singletone)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Load Data from CoreData
//        loadItems()

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
            
            let newItem = Item(context: self.context) //Core Data Object
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            
            self.saveItems()

            self.tableView.reloadData() //Renew tableView Data
        }
                
        alert.addAction(action)

        present(alert, animated: true, completion: nil)
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
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
//MARK: - TableView Delegate Methods
    
    /* for Interaction with TableView */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Check <-> UnCheck applied on Item
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done

        // 1. Edit CoreData Object
//        itemArray[indexPath.row].setValue("Completed", forKey: "title")
                            
        // 2. Delete CoreData Object
//        context.delete(itemArray[indexPath.row])    // Temporary Area
//        itemArray.remove(at: indexPath.row)         // Local variable

        
        //Selection Animated Effect
        tableView.deselectRow(at: indexPath, animated: true)
        
        saveItems() //Update CoreData
        self.tableView.reloadData() //Renew tableView Data
    }
    
    //MARK: - Data Manupulation Methods
    //CoreData CRUD (Create/Read/Update/Delete)
    
    // Save Data into custom.plist
    func saveItems() {
        do {
            try context.save()  // Make CoreData updated
        } catch {
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }

    // Load Data from CoreData
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)

        // Single Query OR Compound Query
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }

        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
}


//MARK: - UISearchBarDelegate
extension TodoListViewController: UISearchBarDelegate {
        
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder() // Make the keyboard go away.
            }
            
        }
    }
    
}

//MARK: - UIPickerViewDelegate
extension TodoListViewController: UIPickerViewDelegate {

}

//MARK: - UIImagePickerControllerDelegate
extension TodoListViewController: UIImagePickerControllerDelegate {

}
