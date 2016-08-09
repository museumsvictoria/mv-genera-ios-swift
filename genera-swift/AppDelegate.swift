//
//  AppDelegate.swift
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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
 
    var buildingDatabase: Bool = false;

    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        //Check for database
       
        
        
           //if database doesn't exist, or isn't complete - import data file.
        if self.databaseExists() == false{
            
            //setup database
            buildingDatabase = true
            let _ = self.persistentStoreCoordinator  //Prevents initial references from different threads creating issues - may need to force creation to main thread.
            self.setupDatabase()
            
        } else
        {
            print("Database found")
            
        }
        
        
        
        //Boilerplate code - split view controller

        if self.window!.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.Pad{
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self

        let masterNavigationController = splitViewController.viewControllers[0] as! UITabBarController
        let navcontroller =  masterNavigationController.viewControllers?[0] as! UINavigationController
        let controller = navcontroller.topViewController as! MasterViewController
        controller.managedObjectContext = self.managedObjectContext
            
  
            
            
            
        }else //Phone
        {
            if (self.window?.rootViewController is IPhoneLoadViewController){
                let loadingScreen = self.window?.rootViewController as! IPhoneLoadViewController
                loadingScreen.managedObjectContext = self.managedObjectContext
            }
        }
        
        if buildingDatabase
        {
           
            
            
            
        }
        else //not building database - perform clean up
        {
            //Check for Gallery entries.
            LocalDefaults.sharedInstance.hasGallery = checkForGalleryEntries()
            
            if self.window!.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.Phone{
                //loading screen
                if (self.window?.rootViewController is IPhoneLoadViewController){
                    let loadingScreen = self.window!.rootViewController as! IPhoneLoadViewController
                  // loadingScreen.setupFinished(nil)
                    loadingScreen.loadingComplete = true
                }
            }


           
        }
     
        //Set application colours
        var customSettings: NSDictionary?
        var barTintColor:String = "255,255,255,1.0"
        var tintColor:String = "255,255,255,1.0"
        var titleTextColor:String = "255,255,255"
        if let path = NSBundle.mainBundle().pathForResource("Custom Settings", ofType: "plist") {
            customSettings = NSDictionary(contentsOfFile: path)
        }
        if let actualDictionary = customSettings {
      
                barTintColor  = actualDictionary.valueForKey("barTintColor") as! String
                tintColor = actualDictionary.valueForKey("tintColor") as! String
                titleTextColor = actualDictionary.valueForKey("titleTextColor")  as! String
            
        }
        

        
        UINavigationBar.appearance().barTintColor = UIColor().fromString(barTintColor)
        UINavigationBar.appearance().tintColor = UIColor().fromString(tintColor)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor().fromString(titleTextColor)]
        UIApplication.sharedApplication().statusBarStyle = .Default
        
    
        return true
    }


    

    // MARK: Database Setup/Checkcode
    
    func checkForGalleryEntries() -> Bool{
        var returnValue:Bool = false
        
        //get gallery objects
        let predicate = NSPredicate(format:"title='Primary'")
        let fetchRequest = NSFetchRequest(entityName:"Gallery")
        fetchRequest.predicate = predicate
        do{
            let currentGallery:[Gallery] =  try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Gallery]
            if currentGallery.count > 0 {
                if currentGallery[0].images?.count > 0{
                returnValue = true
            
                }
            }
        }catch{
            
        }

        return returnValue
        
    }
    
    
    
    
    func setupDatabase() -> Void {
        //Set to a background thread - but send updates
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW,0)) { // 1
            do{
                print("No database Found")
                //create new Managed Object Context - separate from main thread to prevent conflicts
                let coordinator = self.persistentStoreCoordinator
                let backgroundManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType )
                backgroundManagedObjectContext.persistentStoreCoordinator = coordinator
            
                //get data file
            
                if let dataLocation = NSBundle.mainBundle().URLForResource("data", withExtension: ".json")
                {
            
                    if let importData = self.dictionaryWithContentOfJSONFile(dataLocation){
                    
                    //Setup Next Update Check - set to -1 so update check occurs straight away
                  
                        let loadingVersionID:String = importData["versionID"] as! String
                        let loadingDataVersion:DataVersion = NSEntityDescription.insertNewObjectForEntityForName("DataVersion", inManagedObjectContext: backgroundManagedObjectContext) as! DataVersion
                        loadingDataVersion.versionID = Int(loadingVersionID)
                        loadingDataVersion.checkForUpdateAfter = NSDate.init(timeInterval: -1.0, sinceDate: NSDate())
                        
                        //Templates - setup defaults first
                        //Simple Default Template
                        let defaultTemplate:Template = NSEntityDescription.insertNewObjectForEntityForName("Template", inManagedObjectContext: backgroundManagedObjectContext)as!Template
                        defaultTemplate.templateName = "simpledefault"
                        defaultTemplate.tabletTemplate = "iPadTemplate.html"
                        
                        let imageTab:TemplateTab = NSEntityDescription.insertNewObjectForEntityForName("TemplateTab", inManagedObjectContext: backgroundManagedObjectContext)as!TemplateTab
                        imageTab.tabName = "images"
                        imageTab.tabLabel = "Images"
                        imageTab.tabIcon = "images.png"
                        
                        let audioTab:TemplateTab = NSEntityDescription.insertNewObjectForEntityForName("TemplateTab", inManagedObjectContext: backgroundManagedObjectContext) as! TemplateTab
                        audioTab.tabName = "audio"
                        audioTab.tabLabel = "Audio"
                        audioTab.tabIcon = "audio.png"
                        
                        let detailsTab:TemplateTab = NSEntityDescription.insertNewObjectForEntityForName("TemplateTab", inManagedObjectContext: backgroundManagedObjectContext) as! TemplateTab
                        detailsTab.tabName = "details"
                        detailsTab.tabLabel = "Details"
                        detailsTab.tabIcon = "Icons/details.png"
                        
                        
                        
                        //add tabs to default template
                        defaultTemplate.tabOne = imageTab
                        defaultTemplate.tabTwo = detailsTab
                        defaultTemplate.tabThree = audioTab
                    
                        //Get Supergroups
                        var superGroups:[String:SuperGroup] = [String:SuperGroup]()
                        let superGroupList:[[String:String]] = importData["superGroupList"] as! [[String:String]]
                        var superGroupCount = 1 //for inferred order
                        for tmpSuperGroup in superGroupList{
                            //not currently storing superGroups - just dictionary for adding to Group Details.
                            
                            let superGroup:SuperGroup = SuperGroup()
                            superGroup.ID = tmpSuperGroup["superGroupID"]!
                            if let superGroupOrder = Int(tmpSuperGroup["order"]!){
                                superGroup.order = superGroupOrder
                            }else{
                                superGroup.order = superGroupCount
                            }
                            superGroup.label = tmpSuperGroup["label"]!
                            superGroupCount += 1
                            superGroups[superGroup.ID] = superGroup
                        }
                        
                        //Setup Groups
                        let groupArray:[[String: String]] = importData["groupList"] as! [[String: String]]
                        for tmpgroup in groupArray
                        {
                            let testGroup:Group = NSEntityDescription.insertNewObjectForEntityForName("Group", inManagedObjectContext: backgroundManagedObjectContext) as! Group
                            testGroup.label = tmpgroup["label"]
                            testGroup.standardImage = tmpgroup["standardImage"]
                            testGroup.highlightedImage = tmpgroup["highlightedImage"]
                            if let order = tmpgroup["order"]{
                                testGroup.order = Int(order)
                            }
                            testGroup.groupid = tmpgroup["groupid"]
                            if let superGroupID = tmpgroup["superGroupID"]{
                                if let superGroup = superGroups[superGroupID]
                                {
                                    testGroup.superGroup = superGroup.label
                                    testGroup.superGroupOrder = superGroup.order
                                }
                            }

                            print("Group name set to \(tmpgroup["label"])")
                        }//End Group Loop
                        
                        let templateArray:[[String: AnyObject]] = importData["templateList"] as! [[String: AnyObject]]
                        
                        for tmpTemplate in templateArray{
                 
                            let newTemplate:Template = NSEntityDescription.insertNewObjectForEntityForName("Template", inManagedObjectContext: backgroundManagedObjectContext) as! Template
                            newTemplate.templateName = tmpTemplate["templateName"] as? String
                            newTemplate.tabletTemplate = tmpTemplate["tabletTemplate"] as? String
                            
                            let mobileTabs:[[String:String]] = tmpTemplate["mobileTabs"] as! [[String: String]]
                            var tabCounter:Int = 0
                            for tmpMobileTab in mobileTabs{
                                tabCounter += 1
                                var newTemplateTab:TemplateTab
                                let tabName:String = tmpMobileTab["tabName"]!
                                
                                switch tabName{
                                case "audio":
                                    newTemplateTab = audioTab
                             //   case "details":
                             //       newTemplateTab = detailsTab
                             //       newTemplateTab.tabTemplate = tmpMobileTab["tabTemplate"]
                                case "images":
                                    newTemplateTab = imageTab
                                default:
                                    newTemplateTab = NSEntityDescription.insertNewObjectForEntityForName("TemplateTab", inManagedObjectContext: backgroundManagedObjectContext) as! TemplateTab
                                    newTemplateTab.tabName = tabName
                                    newTemplateTab.tabLabel = tmpMobileTab["tabLabel"]
                                    //icon files should be placed in the icon direcotry
                                    if let iconName = tmpMobileTab["tabIcon"]{
                                        newTemplateTab.tabIcon = "Icons/" + iconName
                                    }else
                                    {
                                        newTemplateTab.tabIcon = "missingimage.jpg"
                                    }
                                    newTemplateTab.tabTemplate = tmpMobileTab["tabTemplate"]
                                }
                                switch tabCounter{
                                case 1:
                                    newTemplate.tabOne = newTemplateTab
                                case 2:
                                    newTemplate.tabTwo = newTemplateTab
                                case 3:
                                    newTemplate.tabThree = newTemplateTab
                                case 4:
                                    newTemplate.tabFour = newTemplateTab
                                case 5:
                                    newTemplate.tabFive = newTemplateTab
                                default:
                                    break
                                }
        
                                
                            }
                            
                        } //End Template Loop
                        
                        //Load Speci
                        
                        let speciArray:[[String: AnyObject]] = importData["data"] as! [[String: AnyObject]]
                        let totalNumberOfRecords:Int = speciArray.count
                        var currentRecord:Int = 0
                        var percentComplete:Float = 0.0
                        for tmpSpeci in speciArray{
                            currentRecord += 1
                            percentComplete = Float(currentRecord) / Float(totalNumberOfRecords)
                            dispatch_async(dispatch_get_main_queue()){
                                self.updateLoadProgress(percentComplete)
                            }
                            let newSpeci:Speci = NSEntityDescription.insertNewObjectForEntityForName("Speci", inManagedObjectContext: backgroundManagedObjectContext) as! Speci
                            newSpeci.subgroup = tmpSpeci["subgroup"] as? String
                            newSpeci.identifier = tmpSpeci["identifier"] as? String
                            newSpeci.label = tmpSpeci["label"] as? String
                            newSpeci.labelStyle = tmpSpeci["labelStyle"] as? String
                            newSpeci.sublabel = tmpSpeci["sublabel"] as? String
                            newSpeci.sublabelStyle = tmpSpeci["sublabelStyle"] as? String
                            newSpeci.searchText = tmpSpeci["searchText"] as? String
                            newSpeci.squareThumbnail = tmpSpeci["squareThumbnail"] as? String
                            newSpeci.details = tmpSpeci["details"] as? [String: String]
                            
                            //add Group
                            if let speciGroup:String = (tmpSpeci["group"] as? String) {
                                let predicate = NSPredicate(format:"label=='\(speciGroup)'")
                                let fetchRequest = NSFetchRequest(entityName:"Group")
                                fetchRequest.predicate = predicate
                                do{
                                    let currentGroup:[Group] =  try backgroundManagedObjectContext.executeFetchRequest(fetchRequest) as! [Group]
                                    
                                    if currentGroup.count > 0{
                                        let foundGroup:Group = currentGroup[0]
                                        newSpeci.group = foundGroup
                                    }
                                }catch{
                                    print("Error finding Group")
                                }
                            }
                            //Add Template
                            if let speciTemplate:String = tmpSpeci["template"] as? String{
                                let predicate = NSPredicate(format: "templateName=='\(speciTemplate)'")
                                let fetchRequest = NSFetchRequest(entityName: "Template")
                                fetchRequest.predicate = predicate
                                do{
                                    let currentTemplates:[Template] = try backgroundManagedObjectContext.executeFetchRequest(fetchRequest) as! [Template]
                                    if currentTemplates.count > 0{
                                        let currentTemplate:Template = currentTemplates[0]
                                        newSpeci.template = currentTemplate
                                    }
                                }catch{
                                    print("Error finding and adding tempalte")
                                }
                            } //End Add Template
                            
                            //Add Images
                            var positionCounter = 0
                            if let imageArray:[[String:String]] = tmpSpeci["images"] as? [[String:String]]
                            {
                                for tmpImage in imageArray{
                                    if let newImage:Image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: backgroundManagedObjectContext) as? Image{
                                        
                                        newImage.filename = tmpImage["filename"] as String?
                                        newImage.credit = tmpImage["credit"] as String?
                                        newImage.imageDescription = tmpImage["description"] as String?
                                        newImage.altText = tmpImage["alternateText"] as String?

                                        newImage.order = positionCounter
                                        positionCounter+=1
                                        newImage.object = newSpeci
                                        print ("\(newImage.imageDescription): Postion \(newImage.order)")
                                        
                                        
                                    }
                                    
                                    
                                }
                                
                            }//End Add Images
                            
                            //Add Audio
                            positionCounter = 0
                            print(tmpSpeci["audio"])
                            if let audioArray:[[String:String]] = tmpSpeci["audio"] as? [[String:String]]
                            {
                                
                                for tmpAudio in audioArray{
                                    if let newAudio:Audio = NSEntityDescription.insertNewObjectForEntityForName("Audio", inManagedObjectContext: backgroundManagedObjectContext) as? Audio
                                    {
                                        newAudio.filename = tmpAudio["filename"] as String?
                                        newAudio.credit = tmpAudio["credit"] as String?
                                        if let audioDescription = tmpAudio["description"]{
                                            if audioDescription == ""{
                                                newAudio.audioDescription = "\(newSpeci.label ?? "") call"
                                            }else
                                            {
                                                newAudio.audioDescription = tmpAudio["description"] as String?
                                            }
                                        }

                                        newAudio.order = positionCounter
                                        positionCounter+=1
                                        newAudio.object = newSpeci
                                        
                                    }
                                    
                                    
                                }
                                
                                
                            }//End Add Audio
                            
                            print("Added \(newSpeci.label)")
                        }
                        
                        //Image Gallery Loop
                         let imageArray:[[String: String]] = importData["galleryImages"] as! [[String: String]]
                        //Create Gallery
                        if let newGallery:Gallery = NSEntityDescription.insertNewObjectForEntityForName("Gallery", inManagedObjectContext: backgroundManagedObjectContext) as? Gallery{
                            newGallery.title = "Primary"
                            var order:Int = 0;
                            for tmpGalleryImage in imageArray{
                                if let newImage:Image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: backgroundManagedObjectContext) as? Image{
                                    
                                    newImage.filename = tmpGalleryImage["filename"] as String?
                                    newImage.credit = tmpGalleryImage["credit"] as String?
                                    newImage.imageDescription = tmpGalleryImage["description"] as String?
                                    newImage.altText = tmpGalleryImage["alternateText"] as String?

                                    newImage.order = order
                                    order += 1
                                    newImage.gallery = newGallery
                                    
                                }
                            }
                        }
                        //Save Content
                        
                        try backgroundManagedObjectContext.save()
                        
                        
                    }else
                    {
                        dispatch_async(dispatch_get_main_queue()){
                            self.developerAlert("Fatal Error", message: "The datafile - data.json is not returning a dictionary")
                        }

                    }
                } else
                {
                      //not data file found - should never occur
                    dispatch_async(dispatch_get_main_queue()){
                        self.developerAlert("Fatal Error", message: "The datafile - data.json is missing from the bundle")
                    }
               

                    
                }
            
            
                
                //finished relase interface
                dispatch_async(dispatch_get_main_queue()) {
                    self.importFinished()
                }
            }catch{
                print("Error during async execution")
                print(error)
            }
            }
        
    }
    
    
    
    
    func dictionaryWithContentOfJSONFile(fileURL: NSURL) -> [String: AnyObject]?{
        
        let data:NSData? = NSData.init(contentsOfURL: fileURL)

        if let actualData = data{
            do{
                return try NSJSONSerialization.JSONObjectWithData(actualData, options:[]) as? [String:AnyObject]
            } catch {
                print("Something went wrong")
            }
        }
        
        return nil
        
    }
    
    
    
    func importFinished() -> Void {
    
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationType.DidRefreshDatabase, object:nil)
       
        //Check for Gallery entries.
        LocalDefaults.sharedInstance.hasGallery = checkForGalleryEntries()
        
        //Splitview controller - unlock display
        print("Import Finished")
        buildingDatabase = false
        //Compact devices - show Tab navigation
        if self.window!.traitCollection.userInterfaceIdiom  == UIUserInterfaceIdiom.Phone
        {
            if self.window?.rootViewController is IPhoneLoadViewController{
                if let testController = self.window?.rootViewController as? IPhoneLoadViewController{
                    testController.setupFinished(self)
                }
            }
        }
        
    }
    
    
    func developerAlert(title: String, message:String) -> Void{
        //not data file found - should never occur
        let alertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
        alertView.alertViewStyle = .Default
        alertView.show()
        
    }
    
    func updateLoadProgress(fractionComplete: Float) -> Void{
        print("Fraction Complete: \(fractionComplete)")
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationType.DatabasePercentComplete, object: nil, userInfo: ["percentage":fractionComplete])
    }
    
    func applicationSupportDirectory() -> NSURL {
        // The directory the application uses to store the Core Data store file. This code uses a directory in application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        guard NSFileManager.defaultManager().fileExistsAtPath(urls[urls.count-1].path!) else {
            //Application support directory doesn't exist.
            do
            {
                try NSFileManager.defaultManager().createDirectoryAtURL(urls[urls.count-1], withIntermediateDirectories: true, attributes: nil)
            }
            catch
            {
                
            }
            return urls[urls.count-1]
        }
        
        
        return urls[urls.count-1]
        
        
    }
    
    func databasePath() -> NSURL? {
        //Data base name incorporates the major Version number - updating to a new major Version will create a new database.
        let infoDictionary = NSBundle.mainBundle().infoDictionary;
        let majorVersion = infoDictionary!["CFBundleShortVersonString"]
        let databaseName:String = "genera-\(majorVersion).sqlite"
        return self.applicationSupportDirectory().URLByAppendingPathComponent(databaseName)
        
    }
    
    func databaseExists() -> Bool {
        
        return NSFileManager.defaultManager().fileExistsAtPath(self.databasePath()?.path ?? "")
    }
    

        

    

    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "museumvictoria.com.au.genera_swift" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("genera_swift", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

     lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
 
        
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
         // Addition to boiler plate - creating database to use genera format - statement moved into do/catch
        //let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")

        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            let url = self.databasePath()!
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    


    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

