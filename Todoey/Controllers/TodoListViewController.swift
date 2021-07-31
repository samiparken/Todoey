import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    // Realm
    let realm = try! Realm()

    // Object Array
    var itemArray: Results<Item>?

    //SearchBar
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Prep for Getting Segue
    var selectedCategory: Category? {
        didSet{ //Trigger when the value is set
            loadItems()
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // set navibation bar color from the selected category
        if let colorHex = selectedCategory?.color {
            
            // title
            title = selectedCategory!.name
                    
            // navbar color
            if let navBarColor = UIColor(hexString: colorHex) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                navBarAppearance.largeTitleTextAttributes = [.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                navBarAppearance.backgroundColor = UIColor(hexString: colorHex)
                
                guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
                navBar.standardAppearance = navBarAppearance
                navBar.scrollEdgeAppearance = navBarAppearance
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
            }
            
            // search bar
            searchBar.searchTextField.backgroundColor = FlatWhite()
            searchBar.barTintColor = UIColor(hexString: colorHex)
        }
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
        
        // Swipable Cell from Superclass
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = itemArray?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
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
                    item.done = !item.done
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
    
    //MARK: - Delete Data From Swipe
    //lowerclass
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        
        if let item = self.itemArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)  // delete
                    print("Item Deleted")
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
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
