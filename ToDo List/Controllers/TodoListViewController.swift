//
//  ViewController.swift
//  ToDo List
//
//  Created by Dave on 5/2/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var itemArray: [Item] = [Item]()
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
            self.title = selectedCategory?.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Marker: Tableview Delegate
    //
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        self.saveItems()
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // To delete from core data we need to fetch the object we are looking for
            //
            if let categoryName = selectedCategory?.name, let itemName = itemArray[indexPath.row].title {
                let request: NSFetchRequest<Item> = Item.fetchRequest()
                let categoryPredicate: NSPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", categoryName)
                let itemPredicate: NSPredicate = NSPredicate(format: "title MATCHES %@", itemName)
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, itemPredicate])
                
                if let results = try? context.fetch(request) {
                    for object in results {
                        context.delete(object)
                    }
                    // Save the context and delete the data locally
                    //
                    itemArray.remove(at: indexPath.row)
                    saveItems()
                    tableView.reloadData()
                }
            }
        }
    }

    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        let action = UIAlertAction(title: "Add Item", style: .default) { (_) in
            if let textField = alert.textFields?[0] {
                if textField.text != "" && textField.text != nil {
                    let newItem = Item(context: self.context)
                    newItem.title = textField.text!
                    newItem.done = false
                    newItem.parentCategory = self.selectedCategory
                    
                    self.itemArray.append(newItem)
                    self.tableView.reloadData()
                    self.saveItems()
                }
            }
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Watch Netflix"
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
    // Marker: Save and load from core data
    //
    private func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    private func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// Marker: SearchBar Delegate
//
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        // [cd] makes the search case and diacritic insensitive http://nshipster.com/nspredicate/
        //
        let searchPredicate: NSPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: request, predicate: searchPredicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            // User just cleared the search bar reload everything so their previous search is gone
            //
            loadItems()
            searchBar.resignFirstResponder()
        }
    }
}


































