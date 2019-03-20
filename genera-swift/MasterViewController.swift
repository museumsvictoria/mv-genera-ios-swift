//
//  MasterViewController.swift
//  genera-swift
//
//  Created by Simon Sherrin on 19/01/2016.
/*

 Copyright (c) 2016 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    weak var  detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let application = UIApplication.shared.delegate as! AppDelegate
        self.managedObjectContext = application.managedObjectContext
        self.splitViewController?.preferredDisplayMode = UISplitViewController.DisplayMode.primaryHidden
        
        if self.traitCollection.userInterfaceIdiom  == UIUserInterfaceIdiom.phone
        {
            
        }else
        {
            if let split = self.splitViewController {
                let controllers = split.viewControllers
                self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
            }
        }
        
        //need to refresh groups if database is updated
        NotificationCenter.default.addObserver(self, selector:#selector(MasterViewController.refresh), name: NSNotification.Name(rawValue: NotificationType.DidRefreshDatabase), object: nil  )
        self.title = "Groups"

    }
    
    @objc func refresh() -> Void{

        
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: "Groups")
        do{
            try  self.fetchedResultsController.performFetch()
            self.tableView.reloadData()

        }
        catch{
            print("Group Update Failed")
        }
          
        
        
    }
    

    override func viewWillAppear(_ animated: Bool) {

        if self.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
            self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        }
        
        
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)


    }
    


    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(_ sender: AnyObject) {
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let newManagedObject = NSEntityDescription.insertNewObject(forEntityName: entity.name!, into: context)
             
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        newManagedObject.setValue(Date(), forKey: "timeStamp")
             
        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            let object = self.fetchedResultsController.object(at: indexPath)
                if self.traitCollection.userInterfaceIdiom  == UIUserInterfaceIdiom.pad{
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
              
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem

                controller.navigationItem.leftItemsSupplementBackButton = true
                } else
                {
                    //segue to details
                    
                }
                
            }
        }
        else
        //if segue.identifier == "Show"{
            if let indexPath = self.tableView.indexPathForSelectedRow{
                let object = self.fetchedResultsController.object(at: indexPath) as! Group
             
            
                let controller = (segue.destination as! SpeciListTableViewController)
                controller.selectedGroup = object
                controller.managedObjectContext = self.managedObjectContext!
                controller.title = object.label
                
            }
            
        //}
        
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath) as! NSManagedObject)
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //print("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

         let sectioninfo = self.fetchedResultsController.sections![section]
         let firstGroup:Group = sectioninfo.objects![0] as! Group
         return firstGroup.superGroup
     
    }
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let object = self.fetchedResultsController.object(at: indexPath) as! Group
        cell.textLabel!.text = (object.value(forKey: "label")! as AnyObject).description
        cell.detailTextLabel!.text = object.sublabel!
        if let imagePath:String = object.standardImage?.FileLocation{
            print("imagePath: \(imagePath)")
            if FileManager.default.fileExists(atPath: imagePath){
                cell.imageView!.image = UIImage(contentsOfFile: imagePath)
            } else
            {
                cell.imageView!.image = UIImage(named: "missingthumbnail.jpg")
            }
        }
        

    }
    
    

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        //Clear cache from previous launch - could be removed from production code if there is a significant boost.
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: "Groups")
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entity(forEntityName: "Group", in: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let superGroupSort = NSSortDescriptor(key:"superGroupOrder", ascending:true)
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        
        
        fetchRequest.sortDescriptors = [superGroupSort, sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "superGroupOrder", cacheName: "Groups")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             //print("Unresolved error \(error), \(error.userInfo)")
             abort()
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                self.configureCell(tableView.cellForRow(at: indexPath!)!, atIndexPath: indexPath!)
            case .move:
                tableView.deleteRows(at: [indexPath!], with: .fade)
                tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */

}

