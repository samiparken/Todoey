import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    // Initialize Realm
    let realm = try! Realm()
    
    // Object Array
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Realm: Load Data
        loadCategories()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        
        // Added for fixing nav background color bug
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor.systemBlue
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
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
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category() //Realm Object
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            
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

        // Swipable Cell from Superclass
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categories added yet."
        cell.backgroundColor = UIColor(hexString: (categoryArray?[indexPath.row].color) ?? "1D9BF6")

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
    
    //MARK: - Delete Data From Swipe
    //lowerclass
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        
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
    }
    
    
}
