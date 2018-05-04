# [Core Data](https://developer.apple.com/documentation/coredata) vs [Realm](https://www.realm.io/docs/swift/latest/) 
In this repo you will find a simple todo app that shows basic CRUD operations using Core Data and Realm. The Core Data and Realm branches have the relevant code for each framework. 

##### Note: The Realm branch was setup using Carthage and the frameworks are omitted from git due to size restrictions.

##### Remark: In the code samples below I have removed the calls to ```tableView.reloadData()```. Remember that you must reload your tableView or collectionView whenever you update the data source

In order to understand the code below you must have at least a basic understanding of the application. It's a combination of two rather simple screens. On the first screen you'll find a tableview that allows you to create categories for your todo lists. If you click a category row you can create todo items under that category. 

![Alt Text](https://github.com/dtroupe18/CoreData-vs-Realm/blob/Realm/ToDo%20List/Supporting%20Files/ScreenShots/CategoriesScreenShot.png) ![Alt Text](https://github.com/dtroupe18/CoreData-vs-Realm/blob/Realm/ToDo%20List/Supporting%20Files/ScreenShots/ItemsScreenShot.png)

This data model was chosen because each object is very simple. 
A Category only has a single attribute a name which is a String. 
An Item has three attributes title which is a String, done which is a boolean, and dateCreated which is a Date.

Additionally, this data structure allows use to show the one to many relationship. That is one Category can have many items, but each Item only has one Category.

## Major differences

When using Core Data I allowed it to create the object classes for me. These files are intentionally hidden within Xcode. So you will not see them on the CoreData branch. However, on the Realm branch you'll find two custom classes Category and Item. 

You'll also notice there are extensive differences in the AppDelegate files. Realm requires no setup in AppDelegate where
Core Data requires a lot of extra code in your AppDelegate.


### Core Data TableView Data Source
```swift
var categories = [Category]()
```

### Realm TableView Data Source
```swift
var categories: Results<Category>?
```

### Core Data Context
```swift
let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
```

### Realm
```swift
let realm = try! Realm()
```

### Create with Core Data

```swift
// Create a new object
let newCategory = Category(context: self.context)
newCategory.name = "myCategoryName"

// Update the tableView's data source 
self.categories.append(newCategory)

// Save the context so our new data is persisted
do {
  try context.save()
} catch {
  print("Error saving context: \(error)")
}
```

### Create with Realm
```swift
// Create a new object
let newCategory = Category(name: "myCategoryName")

// Save to Realm there is no need to update our tableView's data source since this is done automagically
do {
  try realm.write {
  realm.add(category)
  }
} catch {
  print("Error saving to category Realm: \(error)")
}
```

### Simple read with Core Data
```swift
do {
  // Fetch all of the category objects
  let request: NSFetchRequest<Category> = Category.fetchRequest()
  categories = try context.fetch(request)
} catch {
  print("Error fetching data from context: \(error)")
}
```

### Simple read with Realm
```swift
// Retrieve all categories from Realm
categories = realm.objects(Category.self)

// Results can be easily sorted
categories = realm.objects(Category.self).sorted(byKeyPath: "name", ascending: true)
```

### Simple update with Core Data
```swift
// itemArray was already filled from a Core Data fetch request so we can just update the data locally and save the context
itemArray[indexPath.row].done = !itemArray[indexPath.row].done
do {
  try context.save()
} catch {
  print("Error saving context: \(error)")
}
```

### Simple update with Realm
```swift
// Whenever you mutate an object that is persisted you need to be inside a write block
do {
  try realm.write {
    item.done = !item.done
  }
} catch {
  print("Error updating item done status: \(error)")
}
```

### Simple delete with Core Data
```swift
// To delete from core data we need to fetch the object we are looking for
let request: NSFetchRequest<Item> = Item.fetchRequest()
let categoryPredicate: NSPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", categoryName)
let itemPredicate: NSPredicate = NSPredicate(format: "title MATCHES %@", itemName)
request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, itemPredicate])
                
if let results = try? context.fetch(request) {
  for object in results {
    context.delete(object)
  }
  // Save the context and delete the data locally
  itemArray.remove(at: indexPath.row)
  do {
    try context.save()
  } catch {
    print("Error saving context: \(error)")
  }
}                
```

### Simple delete with Realm
```swift
do {
  try realm.write {
    realm.delete(todoItems![indexPath.row])
  }
} catch {
  print("Error deleting item from Realm: \(error)")
}
```

### Searching data with Core Data
```swift
let request: NSFetchRequest<Item> = Item.fetchRequest()
let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
let searchPredicate: NSPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, searchPredicate])
request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
do {
  itemArray = try context.fetch(request)
} catch {
  print("Error fetching data from context: \(error)")
}
```

### Searching data with Realm
```swift
// Return any Item object whose name contains the search bar text and sort them in reverse chronological order
todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)

// Note: [cd] makes the search case and diacritic insensitive http://nshipster.com/nspredicate/
```
