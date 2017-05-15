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
        
        //Register NIB for SecondaryTableViewCell and TertiaryTableViewCell
        let twoLabelNib = UINib(nibName: "SecondaryTableViewCell", bundle: nil)
        let threeLabelNib = UINib(nibName: "TertiaryTableViewCell", bundle: nil)
        self.tableView.register(twoLabelNib, forCellReuseIdentifier: "twoLabels")
        self.tableView.register(threeLabelNib, forCellReuseIdentifier: "threeLabels")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        print("\( self.fetchedResultsController.sections?.count ?? 0)")
       return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        print("\(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell
      
        let object:Speci = self.fetchedResultsController.object(at: indexPath)
        if (object.tertiaryLabel != nil){
             cell = tableView.dequeueReusableCell(withIdentifier: "threeLabels", for: indexPath)
        }else{
             cell = tableView.dequeueReusableCell(withIdentifier: "twoLabels", for: indexPath)
        }
      //  let cell = tableView.dequeueReusableCell(withIdentifier: "SpeciCell", for: indexPath)

        self.configureCell(cell, atIndexPath: indexPath)

        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        
        let object:Speci = self.fetchedResultsController.object(at: indexPath)
        if let cellform = cell as? TertiaryTableViewCell {
            cellform.primaryLabel!.text = object.label
            cellform.secondaryLabel!.text = object.sublabel
            cellform.tertiaryLabel!.text = object.tertiaryLabel
            setLabelFontStyle(uiLabel: cellform.primaryLabel, fontStyle: object.labelStyle)
            setLabelFontStyle(uiLabel: cellform.secondaryLabel, fontStyle: object.sublabelStyle)
            setLabelFontStyle(uiLabel: cellform.tertiaryLabel, fontStyle: object.tertiaryLabelStyle)
            if let imagePath:String = object.squareThumbnail?.FileLocation{
                print("imagePath: \(imagePath)")
                if FileManager.default.fileExists(atPath: imagePath){
                    cellform.thumbnail!.image = UIImage(contentsOfFile: imagePath)
                } else
                {
                    cellform.thumbnail!.image = UIImage(named: "missingthumbnail.jpg")
                }
            }
        }
        else if let cellform = cell as? SecondaryTableViewCell{

            cellform.primaryLabel!.text = object.label
            cellform.secondaryLabel!.text = object.sublabel

            setLabelFontStyle(uiLabel: cellform.primaryLabel, fontStyle: object.labelStyle)
            setLabelFontStyle(uiLabel: cellform.secondaryLabel, fontStyle: object.sublabelStyle)

            if let imagePath:String = object.squareThumbnail?.FileLocation{
                print("imagePath: \(imagePath)")
                if FileManager.default.fileExists(atPath: imagePath){
                    cellform.thumbnail!.image = UIImage(contentsOfFile: imagePath)
                } else
                {
                    cellform.thumbnail!.image = UIImage(named: "missingthumbnail.jpg")
                }
            }

        } else {
        
            cell.textLabel!.text = object.label
            cell.detailTextLabel!.text = object.sublabel!
            if object.sublabelStyle == "italic"{
                cell.detailTextLabel!.font = UIFont.italicSystemFont(ofSize: (cell.detailTextLabel?.font.pointSize)!)
            }
            if let imagePath:String = object.squareThumbnail?.FileLocation{
                print("imagePath: \(imagePath)")
                if FileManager.default.fileExists(atPath: imagePath){
                    cell.imageView!.image = UIImage(contentsOfFile: imagePath)
                } else
                {
                    cell.imageView!.image = UIImage(named: "missingthumbnail.jpg")
                }
            }

        }

        
    }
    
    func setLabelFontStyle(uiLabel: UILabel, fontStyle: String?)
    {
        if fontStyle == "italic" {
            uiLabel.font = UIFont.italicSystemFont(ofSize:(uiLabel.font.pointSize))
        }else
        {
            uiLabel.font = UIFont.systemFont(ofSize: (uiLabel.font.pointSize))
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

       let sectioninfo = self.fetchedResultsController.sections![section]

        if let sectionObjects = sectioninfo.objects {
            let firstGroup:Speci = sectionObjects[0] as! Speci
            let speciSubgroup:Subgroup = firstGroup.subgroup as! Subgroup
            return speciSubgroup.label
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

    
    var fetchedResultsController: NSFetchedResultsController<Speci> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        //Clear cache from previous launch - could be removed from production code if there is a significant boost.
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: "Speci")
        
        let fetchRequest:NSFetchRequest<Speci> = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entity(forEntityName: "Speci", in: self.managedObjectContext)
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
        let aFetchedResultsController = NSFetchedResultsController<Speci>(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "subgroup", cacheName: "Speci")
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
    var _fetchedResultsController: NSFetchedResultsController<Speci>?
    
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
    
    
    // MARK: - Navigation
    
    //Becuase we've introduced the custom tableViewCell, the segues are no longer automatically linked, and there doesn't appear to be a way
    //to determine the segue that's been associated with the prototype cell, so we're using the storyboard name to determine which segue to fire.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currentStoryBoard:UIStoryboard = self.storyboard{
            if currentStoryBoard.value(forKey: "name") as! String == "Main-Phone"
            {
                self.performSegue(withIdentifier: "showDetailTabView", sender: self)
            }else
            {
                self.performSegue(withIdentifier: "showDetail", sender: self)
            }
        

        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = self.fetchedResultsController.object(at: indexPath) as! Speci
                //let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController

                controller.detailItem = object
                controller.title = object.label
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftBarButtonItem?.title = self.title
                self.navigationItem.backBarButtonItem?.title = self.title
                self.splitViewController?.toggleMasterView()
            }
        }
        if segue.identifier == "showDetailTabView"{
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = self.fetchedResultsController.object(at: indexPath) as! Speci
                let controller = (segue.destination as! DetailTabBarViewController)
                controller.title = object.label
                controller.selectedSpeci = object
                segue.destination.hidesBottomBarWhenPushed = true
                
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showDetail"{
            //detail view should be the top navigation stack on splitview controller
            if self.splitViewController?.viewControllers[1] is UINavigationController && (self.splitViewController?.viewControllers[1] as! UINavigationController).topViewController is DetailViewController{
                
                let controller = ((self.splitViewController?.viewControllers[1] as! UINavigationController).topViewController as! DetailViewController)
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    let object = self.fetchedResultsController.object(at: indexPath) as! Speci
                    //let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                    //    let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                    
                    controller.detailItem = object
                    controller.title = object.label
                    controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
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
