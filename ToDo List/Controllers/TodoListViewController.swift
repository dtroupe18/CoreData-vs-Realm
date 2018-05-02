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
    
    let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
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

    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Todo", message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        let action = UIAlertAction(title: "Add Item", style: .default) { (_) in
            if let textField = alert.textFields?[0] {
                if textField.text != "" && textField.text != nil {
                    self.itemArray.append(Item(title: textField.text!))
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
    
    // Marker: Save and load data to documents directory using Codable
    //
    
    // Warning: Much like storing information in NSUserDefaults storing everything in one plist means that
    // all of the data must be loaded at once which does not scale well.
    
    private func saveItems() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try? data.write(to: filePath!)
        } catch {
            print("Error encoding data: \(error)")
        }
    }
    
    private func loadItems() {
        if let data = try? Data(contentsOf: filePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding data: \(error)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

