//
//  ViewController.swift
//  ToDo List
//
//  Created by Dave on 5/2/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import RealmSwift


class TodoListViewController: UITableViewController {
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    let realm = try! Realm()
    var todoItems: Results<Item>?
    
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
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            if item.done {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else {
            cell.textLabel?.text = "No Items Added Yet"
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let item = todoItems?[indexPath.row] {
            // Whenever you mutate an object that is persisted you need to be inside a write block
            //
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error updating item done status: \(error)")
            }
        }
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            if todoItems != nil {
                do {
                    try realm.write {
                        realm.delete(todoItems![indexPath.row])
                    }
                } catch {
                    print("Error deleting item from Realm: \(error)")
                }
                tableView.reloadData(with: .fade)
            }
        }
    }

    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        let action = UIAlertAction(title: "Add Item", style: .default) { (_) in
            if let textField = alert.textFields?[0] {
                if textField.text != "" && textField.text != nil, let parentCategory = self.selectedCategory {
                    
                    // Save items to Realm
                    //
                    do {
                        try self.realm.write {
                            let newItem = Item(title: textField.text!)
                            // Add this item to its parent. This must be done in a write block
                            //
                            parentCategory.items.append(newItem)
                            self.realm.add(newItem)
                        }
                    } catch {
                        print("Error saving item to Realm: \(error)")
                    }
                    self.tableView.reloadData()
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
    
    // Load items from Realm
    //
    private func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
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
        // [cd] makes the search case and diacritic insensitive http://nshipster.com/nspredicate/
        //
        if searchBar.text != nil {
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
            tableView.reloadData()
        }
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

