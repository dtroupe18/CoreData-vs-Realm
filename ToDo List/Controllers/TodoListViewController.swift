//
//  ViewController.swift
//  ToDo List
//
//  Created by Dave on 5/2/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    var itemArray = [Item]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let item1 = Item(title: "Find Mike")
        let item2 = Item(title: "Go home")
        let item3 = Item(title: "Take out trash", done: true)
        
        itemArray.append(item1)
        itemArray.append(item2)
        itemArray.append(item3)
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
        tableView.reloadRows(at: [indexPath], with: .fade)
    }

    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Todo", message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        let action = UIAlertAction(title: "Add Item", style: .default) { (_) in
            if let textField = alert.textFields?[0] {
                if textField.text != "" && textField.text != nil {
                    self.itemArray.append(Item(title: textField.text!))
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

