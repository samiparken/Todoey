
import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {

    // Realm
    let realm = try! Realm()

    // Object Array
    var itemArray: Results<Item>?

    // Prep for Getting Segue
    var selectedCategory: Category? {
        didSet{ //Trigger when the value is set
            loadItems()
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
                
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
            
            if let currentCategory = self.selectedCategory {
                // Realm: Save newItem
                do {
                    try self.realm.write{
                        let newItem = Item() //Realm Object
                        newItem.title = textField.text!
                        newItem.done = false
//                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving item \(error)")
                }
            }
            self.tableView.reloadData() //Renew tableView Data
        }
        
        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }
    
//MARK: - TableView Datasource Methods
    
    /* Return How many Rows */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    /* Called as many as the Number of Rows */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Cell Title
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        if let item = itemArray?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
//MARK: - TableView Delegate Methods
    
    /* for Interaction with TableView */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Realm: Update
        if let item = itemArray?[indexPath.row] {
            do {
                try realm.write {
                    if item.done == false { item.done = !item.done } // check <-> uncheck
                    else { realm.delete(item) } // delete item
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }

        //Selection Animated Effect
        tableView.deselectRow(at: indexPath, animated: true)

        self.tableView.reloadData() //Renew tableView Data
    }
    
    //MARK: - Data Manupulation Methods

    // Load Data from Realm
    func loadItems() {

        // Load All Items from SelectedCategory
        itemArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
}


//MARK: - UISearchBarDelegate
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Realm Quary + Sorting
        itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder() // Make the keyboard go away.
            }
        } else {
            itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        }
    }

}

//MARK: - UIPickerViewDelegate
extension TodoListViewController: UIPickerViewDelegate {

}

//MARK: - UIImagePickerControllerDelegate
extension TodoListViewController: UIImagePickerControllerDelegate {

}
