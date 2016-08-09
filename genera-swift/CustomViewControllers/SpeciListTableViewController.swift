//
//  SpeciListTableViewController.swift
//  genera-swift
//
//  Created by Simon Sherrin on 22/01/2016.
/*

 Copyright (c) 2016 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

import UIKit
import CoreData

class SpeciListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var _selectedGroup:Group? = nil
    var _managedObjectContext:NSManagedObjectContext? = nil
    
    var selectedGroup:Group{
        get{
            return _selectedGroup!
        }
        
        set{
            _selectedGroup = newValue
            _fetchedResultsController = nil //reset controller
            self.title = newValue.label
        }
        
    }
    
    
    
    var managedObjectContext:NSManagedObjectContext{
        get{
            return _managedObjectContext!
        }
        set
        {
            _managedObjectContext = newValue
        }
    }
    
    func refreshTable(){
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = selectedGroup.label
        self.tableView.rowHeight = 75.0;
        //TODO - remove t
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        print("\( self.fetchedResultsController.sections?.count ?? 0)")
       return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        print("\(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SpeciCell", forIndexPath: indexPath)

        self.configureCell(cell, atIndexPath: indexPath)

        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Speci
        cell.textLabel!.text = object.label
        cell.detailTextLabel!.text = object.sublabel!
        if object.sublabelStyle == "italic"{
            cell.detailTextLabel!.font = UIFont.italicSystemFontOfSize((cell.detailTextLabel?.font.pointSize)!)
        }
        if let imagePath:String = object.squareThumbnail!.FileLocation{
            print("imagePath: \(imagePath)")
            if NSFileManager.defaultManager().fileExistsAtPath(imagePath){
                cell.imageView!.image = UIImage(contentsOfFile: imagePath)
            } else
            {
                cell.imageView!.image = UIImage(named: "missingthumbnail.jpg")
            }
        }
        
        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

       let sectioninfo = self.fetchedResultsController.sections![section]

        if let sectionObjects = sectioninfo.objects {
            let firstGroup:Speci = sectionObjects[0] as! Speci
            return firstGroup.subgroup
        } else
        {
            return "Unknown Group"
        }
        

       
        
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        //Clear cache from previous launch - could be removed from production code if there is a significant boost.
        NSFetchedResultsController.deleteCacheWithName("Speci")
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Speci", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 100
        
        // Edit the sort key as appropriate.
        let subgroupSort = NSSortDescriptor(key:"subgroup", ascending:true)
        let sortDescriptor = NSSortDescriptor(key: "label", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        
        
        fetchRequest.sortDescriptors = [subgroupSort, sortDescriptor]

        fetchRequest.predicate = NSPredicate(format: "group.label = '\(selectedGroup.label!)'")
        print("group.label = '\(selectedGroup.label)'")
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "subgroup", cacheName: "Speci")
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
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    /*
    // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
    // In the simplest, most efficient, case, reload the table view.
    self.tableView.reloadData()
    }
    */
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Speci
                //let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController

                controller.detailItem = object
                controller.title = object.label
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftBarButtonItem?.title = self.title
                self.navigationItem.backBarButtonItem?.title = self.title
                self.splitViewController?.toggleMasterView()
            }
        }
        if segue.identifier == "showDetailTabView"{
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Speci
                let controller = (segue.destinationViewController as! DetailTabBarViewController)
                controller.title = object.label
                controller.selectedSpeci = object
                segue.destinationViewController.hidesBottomBarWhenPushed = true
                
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "showDetail"{
            //detail view should be the top navigation stack on splitview controller
            if self.splitViewController?.viewControllers[1] is UINavigationController && (self.splitViewController?.viewControllers[1] as! UINavigationController).topViewController is DetailViewController{
                
                let controller = ((self.splitViewController?.viewControllers[1] as! UINavigationController).topViewController as! DetailViewController)
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Speci
                    //let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                    //    let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                    
                    controller.detailItem = object
                    controller.title = object.label
                    controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                    controller.navigationItem.leftBarButtonItem?.title = self.title
                    self.navigationItem.backBarButtonItem?.title = self.title
                   // self.splitViewController?.toggleMasterView()
                }

                return false
            }else{
            
                return true
            
            }
            
            
        }else{
            
            return true
        }
        
    }
    
    
    //MARK: - Fetched Results
    

}
