//
//  SpeciSearchTableViewController.swift
//  genera-swift
//
//  Created by Simon Sherrin on 25/01/2016.
/*


 Copyright (c) 2016 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

import UIKit
import CoreData


class SpeciSearchTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate  {

    let searchController = UISearchController(searchResultsController: nil)
    var speciResults = [Speci]()
    
    var detailViewController:DetailViewController? = nil
    
    var _managedObjectContext:NSManagedObjectContext? = nil
    
    
    var managedObjectContext:NSManagedObjectContext{
        get{
            return _managedObjectContext!
        }
        set
        {
            _managedObjectContext = newValue
        }
    }
    
    var existingSearchTerm:String = ""
    let os = ProcessInfo().operatingSystemVersion
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let application = UIApplication.shared.delegate as! AppDelegate
        self.managedObjectContext = application.managedObjectContext
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.delegate = self
        searchController.searchBar.delegate = self
        if os.majorVersion == 8 {
            searchController.hidesNavigationBarDuringPresentation = true
        }else
        {
            searchController.hidesNavigationBarDuringPresentation = false
        }
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
      
        self.tableView.rowHeight = 75.0
        self.title = "Search"
     //   searchController.active = true
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        if !existingSearchTerm.isEmpty {
            searchController.searchBar.text = existingSearchTerm
        }
        
        self.preferredContentSize = CGSize(width: 400.0,height: 600.0)
        
        //Register NIB for SecondaryTableViewCell and TertiaryTableViewCell
        let twoLabelNib = UINib(nibName: "SecondaryTableViewCell", bundle: nil)
        let threeLabelNib = UINib(nibName: "TertiaryTableViewCell", bundle: nil)
        self.tableView.register(twoLabelNib, forCellReuseIdentifier: "twoLabels")
        self.tableView.register(threeLabelNib, forCellReuseIdentifier: "threeLabels")
        
    
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // tableView.tableHeaderView?.hidden = false
        //self.navigationController?.navigationBar.translucent = false
        searchController.isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if speciResults.count == 0{
            return 0}
        else
        {
            return speciResults.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "SpeciCell", for: indexPath)

        // Configure the cell...
        let object:Speci = self.speciResults[(indexPath as NSIndexPath).row]
        
        
        
        var cell:UITableViewCell
      
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
        
           let object:Speci = self.speciResults[(indexPath as NSIndexPath).row]
        
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
        
        /* Old Cell Code - for storyboard protoype cell
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
         */
        
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
    
    
    //Becuase we've introduced the custom tableViewCell, the segues are no longer automatically linked, and there doesn't appear to be a way
    //to determine the segue that's been associated with the prototype cell. In this case, the realDetailViewController property is being used to determine if 
    //the primary controller is a splitview controller. If it isn't, the "iPhone" segue is fired. 
    //TO DO: Revaluate if this or the method used in SpeciListTableViewController is the best approach.
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let realDetailViewController = detailViewController{
            
            realDetailViewController.detailItem = speciResults[(indexPath as NSIndexPath).row]
            realDetailViewController.updateNavigationTree()
            
            if let currentSearch = searchController.searchBar.text{
            realDetailViewController.searchTerm = currentSearch
            }
            self.presentingViewController!.dismiss(animated: true, completion: nil)
        }else
        {
            self.performSegue(withIdentifier: "showDetailTabView", sender: self)
           
        }
    }

    
    func dismissMe(){
        self.presentingViewController?.dismiss(animated: true, completion:nil)
        
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

    /*
    // MARK: - Navigation

     
     
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //Becuase we've introduced the custom tableViewCell, the segues are no longer automatically linked, and there doesn't appear to be a way
    //to determine the segue that's been associated with the prototype cell, so we're using the storyboard name to determine which segue to fire.
    

    
    // MARK: - SearchUpdater
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }

    func filterContentForSearchText(_ searchText:String, scope:String = "All"){
    
            
            //use context
         /*   NSEntityDescription *entity = [NSEntityDescription entityForName:"Speci" inManagedObjectContext:self.managedObjectContext];
            NSFetchRequest	*request = [[NSFetchRequest alloc] init];
            request.entity = entity;
            request.predicate = predicate;
            
            // Edit the sort key as appropriate.
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortField ascending:YES];
            NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
            
            [request setSortDescriptors:sortDescriptors];
            
            NSArray	*results = [context executeFetchRequest:request error:nil];
            [sortDescriptor release];
            [sortDescriptors release];
            [request release];
            */
        if searchText.characters.count > 0 { //make sure there's something to search on
            do{
                let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Speci")
                //Split search text on spaces to build predicate
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

                
                if let fetchResults = try self.managedObjectContext.fetch(fetchRequest) as? [Speci] {
                    speciResults = fetchResults
                }
                
                speciResults.sort{ $0.label!.localizedCaseInsensitiveCompare($1.label!) == ComparisonResult.orderedAscending}
                
            }catch
            {
                
            }
        
            
            
            tableView.reloadData()
        }
        
            
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = speciResults[(indexPath as NSIndexPath).row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                
            }
            
            
            
        }
        if segue.identifier == "showDetailTabView"{
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = self.speciResults[(indexPath as NSIndexPath).row]
                let controller = (segue.destination as! DetailTabBarViewController)
                controller.title = object.label
                controller.selectedSpeci = object
                
                segue.destination.hidesBottomBarWhenPushed = true
                
            }
        }

        
        
    }
    

    
    
}
