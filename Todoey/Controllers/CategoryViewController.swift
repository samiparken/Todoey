/* Organized by Commits */

// 1 - Apply UserDefaults.plist & Custom.plist
// 2 - CoreData


import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    // Object Array
    var categoryArray = [Category]()
    
    // For CoreData
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load Data from CoreData
        loadCategories()
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
            
            let newCategory = Category(context: self.context) //Core Data Object
            newCategory.name = textField.text!
            self.categoryArray.append(newCategory)
            
            self.saveCategories()
            self.tableView.reloadData() //Renew tableView Data
        }
                
        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }

    // MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }

    /* Called as many as the Number of Rows */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Cell Title
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name!
    
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
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    //CoreData CRUD (Create/Read/Update/Delete)
    
    // Save Data into CoreData
    func saveCategories() {
        do {
            try context.save()  // Make CoreData updated
        } catch {
            print("Error saving context \(error)")
        }
        loadCategories()
    }

    // Load Data from CoreData
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
}
