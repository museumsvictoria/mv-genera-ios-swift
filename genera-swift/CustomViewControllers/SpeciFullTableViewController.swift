//
//  SpeciFullTableViewController.swift
//  genera-swift
//
//  Created by Simon Sherrin on 27/01/2016.
/*
 Copyright (c) 2016 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

import UIKit
import CoreData

class SpeciFullTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {

     var managedObjectContext:NSManagedObjectContext? = nil
     let searchController = UISearchController(searchResultsController: nil)
     let os = ProcessInfo().operatingSystemVersion
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        let application = UIApplication.shared.delegate as! AppDelegate
        self.managedObjectContext = application.managedObjectContext
        self.tableView.estimatedRowHeight = 75 // added so that searchController is sized correctly on iOS 8
        //Search Bar Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.delegate = self
        searchController.searchBar.delegate = self

        searchController.hidesNavigationBarDuringPresentation = false
     
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.sizeToFit()  //required for search bar to appear in iOS 8 - otherwise 0 height.
        
        
        //Title for different for iPad and iPhone Version
        if self.traitCollection.userInterfaceIdiom  == UIUserInterfaceIdiom.phone {
            self.title = "A to Z"
        }else{
            self.title = "Search"
        }
        
        self.tableView.rowHeight = 75.0;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        print("Number of Sections: \(self.fetchedResultsController.sections?.count ?? 0)")
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpeciCell", for: indexPath)

        self.configureCell(cell, atIndexPath: indexPath)

        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let object = self.fetchedResultsController.object(at: indexPath) 
        cell.textLabel!.text = object.label
        cell.detailTextLabel!.text = object.sublabel!
      /*  if ([managedSpeci.sublabelStyle isEqualToString:@"italic"]) {
            NSLog(@"italicSection");
            [cell detailTextLabel].font = [UIFont fontWithName:@"Helvetica-Oblique" size:14];
            [cell detailTextLabel].textColor = [UIColor colorWithRed:0.258 green:.258 blue:.258 alpha:1];
        } else
        {
            [cell detailTextLabel].font = [UIFont fontWithName:@"Helvetica" size:14];
            [cell detailTextLabel].textColor = [UIColor colorWithRed:0.258 green:.258 blue:.258 alpha:1];
        }
        */
        
        if object.sublabelStyle == "italic"{
         cell.detailTextLabel!.font = UIFont.italicSystemFont(ofSize: (cell.detailTextLabel?.font.pointSize)!)
        }
        
        if let imagePath:String = object.squareThumbnail?.FileLocation{
           
            if FileManager.default.fileExists(atPath: imagePath){
                cell.imageView!.image = UIImage(contentsOfFile: imagePath)
            } else
            {
                cell.imageView!.image = UIImage(named: "missingthumbnail.jpg")
            }
        }
        
        
    }

        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            
            return self.fetchedResultsController.sectionIndexTitles[section]
        }
 
   override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.fetchedResultsController.sectionIndexTitles
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


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
               
    
    }

    // Mark: - Search Updating
    
    func updateSearchResults(for searchController: UISearchController) {
       // filterContentForSearchText(searchController.searchBar.text!)
        _fetchedResultsController = nil
        tableView.reloadData()
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = self.fetchedResultsController.object(at: indexPath)
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
                let object = self.fetchedResultsController.object(at: indexPath)
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
                    let object = self.fetchedResultsController.object(at: indexPath)
 
                    
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

    
    //MARK: - Fetch Results
    var fetchedResultsController: NSFetchedResultsController<Speci> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        //Clear cache from previous launch - could be removed from production code if there is a significant boost.
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: "Speci")
        
        let fetchRequest:NSFetchRequest<Speci> = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entity(forEntityName: "Speci", in: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 100
        
    
        //Set a predicate if the search controller text is not empty
        if let searchText = searchController.searchBar.text{
        if !searchText.isEmpty
            {
                let searchterms:[String] = searchText.characters.split{$0 == " "}.map(String.init)
                var searchQuery:String = ""
                
                if searchterms.count >= 1{
                    searchQuery = "searchText MATCHES[cd] \"(.* )?\(searchterms[0]).*\""
                    if searchterms.count > 1{
                        for i in 1..<searchterms.count{
                            searchQuery = searchQuery + " AND searchText MATCHES[cd] \"(.* )?\(searchterms[i]).*\""
                            
                        }
                        
                        
                    }
                    let predicate = NSPredicate(format: searchQuery)
                    fetchRequest.predicate = predicate
                    
                }
            }
        }
        // Edit the sort key as appropriate.
        
    
    
        let sortDescriptor = NSSortDescriptor(key: "label", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))

        
        fetchRequest.sortDescriptors = [sortDescriptor]
        

        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController<Speci>(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "firstLetter", cacheName: "Speci")
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
    var _fetchedResultsController: NSFetchedResultsController<Speci>? = nil
    
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

    
}
