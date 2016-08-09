
//
//  DetailViewController.swift
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
import WebKit

class DetailViewController: UIViewController, UIPageViewControllerDataSource, iPadHomeViewControllerDelegate{

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var detailWebView:UIView!
    
    weak var detailWebController:MVWebWrapperViewController?
    weak var imagepageController:UIPageViewController?
    @IBOutlet weak var ViewSwitcherControl: UISegmentedControl!
    weak var homeViewController:iPadHomeViewController?
    weak var searchPopover:SpeciSearchTableViewController?
    
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var aboutViewTopConstraint: NSLayoutConstraint!
     @IBOutlet weak var aboutViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var homeButton: UIBarButtonItem!
    

    
    
    
    var viewState:ViewState = ViewState.Split //Status holder for view test: 0 no image, 1 split , 2 full screen image, 3 split
    
    
    let portaitImageProporition:CGFloat = 0.48
    let landscapeImageProportion:CGFloat = 0.55
    
    
    var isHomePageActive: Bool = true
    var isAboutPageActive: Bool = false
    
    
    
    var detailItem: AnyObject? {
        didSet {
            
            // Update the view.
            self.configureView()
            
        }
    }

    //maintain previous search
    var searchTerm:String = ""
    
    @IBAction func ViewSwitcherControlChanged(sender: UISegmentedControl) {
        
        let orientation:UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation; //Current Orientation
        self.view.layoutIfNeeded()
        if (sender.selectedSegmentIndex == 0){ //Text only
            imageViewHeightConstraint.constant = 0
            viewState = .WebOnly
            
        }else if (sender.selectedSegmentIndex == 1){// Split Only
            if orientation == UIInterfaceOrientation.LandscapeLeft || orientation == UIInterfaceOrientation.LandscapeRight {
                // orientation is landscape ->
                imageViewHeightConstraint.constant = floor(self.view.frame.height * landscapeImageProportion)
                
            }  else {
                // orientation is portrait
                imageViewHeightConstraint.constant = floor(self.view.frame.height * portaitImageProporition)
            }
            viewState = .Split
            
        }
            
        else {//Image Only
            imageViewHeightConstraint.constant = self.view.frame.height
            viewState = .ImageOnly
        }
        
        UIView.animateWithDuration(0.5, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if self.navigationController?.splitViewController?.collapsed == false {
            self.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            if let speci = self.detailItem as? Speci{
                if let group = speci.group as? Group{
                    self.navigationItem.leftBarButtonItem?.title = group.label
                }
            }
        }
        
        

        if let detail = self.detailItem as? Speci{
            if let label = self.detailDescriptionLabel {
                label.text = detail.valueForKey("label")!.description
            }
            self.title = detail.label
            //update Web Details
            detailWebController?.speci = detail
            if let tabletTemplate = (detail.template as! Template).tabletTemplate{
                detailWebController?.templateFilename = tabletTemplate
            }
            detailWebController?.setupTemplate()


            //Update Image view
            imagepageController?.dataSource = nil
            imagepageController?.dataSource = self
            let pageContentViewController = self.viewControllerAtIndex(0)
            if (pageContentViewController != nil ){
                imagepageController?.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
            }
            
            //Hide About/Homeview if it's visible
            if homeViewController?.view.hidden == false{
                
                HideHomeView()

                enableViewSwitcher()
            }
            
            self.navigationController?.splitViewController?.preferredDisplayMode = .PrimaryHidden
        }

        

        
        
    }
    
    
    func disableViewSwitcher(){
        ViewSwitcherControl.enabled = false
        ViewSwitcherControl.userInteractionEnabled = false
        print("Switcher - disabled")
    }
    
    func enableViewSwitcher(){
        ViewSwitcherControl.enabled = true
        ViewSwitcherControl.userInteractionEnabled = true
        print("Switcher - enabled")
    }
    
    
    func updateNavigationTree(){
        if let speci = detailItem as? Speci{
            if  let navStack = self.splitViewController?.viewControllers[0].childViewControllers{
                if navStack.count > 1 {
                    //already have Speci List
                    let speciList = navStack[1] as! SpeciListTableViewController
                    if let speciGroup = speci.group as? Group{
                        if speciList.selectedGroup != speciGroup {
                            speciList.selectedGroup = speciGroup
                            speciList.title = speciGroup.label
                            speciList.refreshTable()
                        }
                    }
                    
                }
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
                disableViewSwitcher()
               self.configureView()
               self.title = "Home"
             // disableViewSwitcher()
    }

    override func viewDidAppear(animated: Bool) {
        let orientation:UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation; //Current Orientation
        if orientation == UIInterfaceOrientation.LandscapeLeft || orientation == UIInterfaceOrientation.LandscapeRight {
            // orientation is landscape ->
            imageViewHeightConstraint.constant = floor(self.view.frame.height * landscapeImageProportion)
            
        }  else {
            // orientation is portrait
            imageViewHeightConstraint.constant = floor(self.view.frame.height * portaitImageProporition)
        }


        
        super.viewDidAppear(animated)
        
        /*if let actualDetailItem = self.detailItem as? Speci{
           // detailWebController = MVWebViewController(nibName: "MVWebViewController", bundle: nil)
            if (detailWebController == nil){
                detailWebController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SpeciWebView") as? MVWebViewController
            }
            if let tabletTemplate = (actualDetailItem.template as! Template).tabletTemplate{
               detailWebController?.templateFilename = tabletTemplate
            }
            detailWebController?.speci = actualDetailItem
            detailWebView.addSubview((detailWebController?.view)!)
            
        }*/
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSearch" {
            
            let controller = (segue.destinationViewController as! SpeciSearchTableViewController)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            controller.managedObjectContext = appDelegate.managedObjectContext
            controller.detailViewController = self
            controller.existingSearchTerm = searchTerm
            searchPopover = controller

        }
        if segue.identifier == "embedPageViewController"{
            imagepageController = segue.destinationViewController as? UIPageViewController
            imagepageController?.view.backgroundColor = UIColor.blackColor()
            imagepageController?.dataSource = self
            if (detailItem != nil){
                let pageContentViewController = self.viewControllerAtIndex(0)
                if (pageContentViewController != nil){
                    imagepageController?.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
                }
            }
        }
       if segue.identifier == "embedWebViewController"{
            detailWebController = segue.destinationViewController as? MVWebWrapperViewController
           // detailWebController?.view.backgroundColor = UIColor.blackColor()
            if let actualDetailItem = detailItem as? Speci{
                detailWebController?.speci = actualDetailItem
                if let tabletTemplate = (actualDetailItem.template as! Template).tabletTemplate{
                    detailWebController?.templateFilename = tabletTemplate
                }
            }
        
        }
        if segue.identifier == "embedHomeViewController"{
            homeViewController = segue.destinationViewController as? iPadHomeViewController
            homeViewController!.delegate = self
        }
        
        if segue.identifier == "showGallery"{
             // self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil) //hide popover controllers if open
            if (searchPopover != nil){
                searchPopover?.dismissMe()
                searchPopover = nil
            }
            
        }
        
    }
    
    //View Switching Functions
    
    @IBAction func ToggleHomeScreen(sender: AnyObject) {
        
        ShowHomeView()
        
        
    }
    
    
    
    
    
    
    func ShowHomeView(){
        if homeViewController?.view.hidden == true {
                self.view.layoutIfNeeded()
                self.title = "home"
                self.homeViewController?.view.hidden = false
                self.aboutViewTopConstraint.constant = 0
                self.aboutViewBottomConstraint.constant = 0
            UIView.animateWithDuration(0.5
                , animations: {
                    self.view.layoutIfNeeded()

                    
                }
            )
        }
        self.title = "Home"
        if isAboutPageActive {
            homeViewController?.hideAbout()
        }
        else{
            homeViewController?.homePageActive()
        }
        homeButton.enabled = false
        disableViewSwitcher()
    }
    
    func HideHomeView(){
        self.view.layoutIfNeeded()
        self.aboutViewTopConstraint.constant = self.view.frame.height
        self.aboutViewBottomConstraint.constant = -self.view.frame.height
            UIView.animateWithDuration(0.5, animations: {
           
                //TO DO - Chose between height and width depending on orientation and animate change.
                self.view.layoutIfNeeded()
               
                },completion: {finished in if(finished){
                    self.homeViewController?.view.hidden = true
                    UIView.animateWithDuration(0){}
                    // need to work on animation in and out.
                    }
            })
            if (self.detailItem != nil){ //a speci is selected - set view title to speci title
                let tempSpeci =  self.detailItem as! Speci
                self.title = tempSpeci.label
                
            }
        isHomePageActive = false
        isAboutPageActive = false

        homeButton.enabled = true
        disableViewSwitcher()
    }

    
    

    //iPadHomeDelegate Protocol functions
    
    func aboutShown(){
        homeButton.enabled = true
        self.title = "About"
        isAboutPageActive = true
        disableViewSwitcher()
    }

    func aboutHidden(){
        homeButton.enabled = false
        isAboutPageActive = false
        disableViewSwitcher()
        if homeViewController!.view.hidden == false {self.title = "Home"} else {self.title = (self.detailItem as? Speci)?.label}
    }
    
    func showMaster(){
        self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.PrimaryOverlay
        
    }
    

    // PageView Data Source Functions
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
  
        if let realSpeci = self.detailItem as? Speci{
        
                var index = (viewController as! PageContentViewController).pageIndex
                index += 1
                if(index >= realSpeci.sortedImages().count){
                    return nil
                }
                return self.viewControllerAtIndex(index)

        }else
        {
            return nil
        }
        
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
       
        var index = (viewController as! PageContentViewController).pageIndex
        if(index <= 0){
            return nil
        }
        index -= 1
        return self.viewControllerAtIndex(index)
        
    }
    
    func viewControllerAtIndex(index : Int) -> UIViewController? {
        
        if let realSpeci = self.detailItem as? Speci{
            let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageContentController") as! PageContentViewController
            
            if((realSpeci.sortedImages().count == 0) || (index >= realSpeci.sortedImages().count )) {
                pageContentViewController.imageFile = "missingthumbnail.jpg".FileLocation ?? ""
                pageContentViewController.descriptionText = "No Images"
                pageContentViewController.creditText = "No Images"
                pageContentViewController.pageIndex = index
            }else{

            // var imageArray = self.selectedSpeci!.sortedImages()
                pageContentViewController.imageFile = realSpeci.sortedImages()[index].filename?.FileLocation ?? ""
                pageContentViewController.descriptionText = realSpeci.sortedImages()[index].imageDescription ?? ""
                pageContentViewController.creditText = realSpeci.sortedImages()[index].credit ?? ""
                pageContentViewController.altText = realSpeci.sortedImages()[index].altText ?? ""
                pageContentViewController.pageIndex = index
            }

            return pageContentViewController
        }else
        {
            return nil
        }
        
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return (self.detailItem as? Speci)?.images?.count ?? 0
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
   
    
    //Test of constraint changes
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
       
        if viewState == .Split||viewState == .SecondSplit {
            let orientation:UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation; //Current Orientation
            if orientation == UIInterfaceOrientation.LandscapeLeft || orientation == UIInterfaceOrientation.LandscapeRight {
                // orientation is landscape -> so Going to Portrait
                imageViewHeightConstraint.constant = floor(size.height * portaitImageProporition)
                
            }  else {
                // orientation is portrait -> going to landscape
                imageViewHeightConstraint.constant = floor(size.height * landscapeImageProportion)
            }
            
            //self.imagepageController?.view.setNeedsUpdateConstraints()
       // (imageViewHeightConstraint.firstItem as? UIView)?.setNeedsUpdateConstraints()
        } else if viewState == .ImageOnly {
             imageViewHeightConstraint.constant = size.height//self.view.frame.width //Width will become the height on rotation.
        } else if viewState == .WebOnly{
             imageViewHeightConstraint.constant = 0
        }
        
        self.view.setNeedsLayout()
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

            
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
     

        
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        
        
    }
    
    

    
    
}

enum ViewState
{
    case WebOnly,Split,ImageOnly,SecondSplit
    
}
