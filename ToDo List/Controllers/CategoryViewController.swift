//
//  CategoryViewController.swift
//  ToDo List
//
//  Created by Dave on 5/2/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {

    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    var categories: Results<Category>?
    
    // Realm documentation says force unwrapping here is ok
    //
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }

    // MARK: - TableView Delegate
    //
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Yet"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            if categories != nil {
                print("deleting data")
                do {
                    try! realm.write {
                        realm.delete(categories![indexPath.row])
                    }
                }
                tableView.reloadData(with: .fade)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? TodoListViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categories?[indexPath.row]
            }
        }
    }
    
    // Marker: CoreData save and load
    //
    private func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving to category Realm: \(error)")
        }
        self.tableView.reloadData()
    }
    
    private func loadCategories() {
        // retrieve all Categories from the default Realm and sort by their name
        //
        categories = realm.objects(Category.self).sorted(byKeyPath: "name", ascending: true)
        tableView.reloadData()
    }
    
    // Marker: Adding new Categories
    //
    @IBAction func addBarButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        let action = UIAlertAction(title: "Add Category", style: .default) { (_) in
            if let textField = alert.textFields?[0] {
                if textField.text != "" && textField.text != nil {
                    let newCategory = Category(name: textField.text!)
                    // newCategory.name = textField.text!
                    
                    // We don't need to append the new item because Results containers are auto updating
                    // self.categories.append(newCategory)
                    self.save(category: newCategory)
                }
            }
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Shopping List"
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension UITableView {
    func reloadData(with animation: UITableViewRowAnimation) {
        reloadSections(IndexSet(integersIn: 0..<numberOfSections), with: animation)
    }
}
