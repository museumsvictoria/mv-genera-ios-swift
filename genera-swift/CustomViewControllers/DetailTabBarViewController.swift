//
//  DetailTabBarViewController.swift
//  genera-swift
//
//  Created by Simon Sherrin on 16/02/2016.
/*

 Copyright (c) 2016 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

import UIKit
import CoreData

class DetailTabBarViewController: UITabBarController, UIPageViewControllerDataSource, PageContentViewControllerDelegate {

    
    var selectedSpeci: Speci?
   

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        
        // Do any additional setup after loading the view.
    
        //cycle through view controllers and add appropriate values
      /*  if let finalViewControllers = self.viewControllers{
        //views may not be in the correct positions
            for viewController in finalViewControllers{
                
                    if viewController is SpeciImageCollectionViewController
                    {
                        let actualView = viewController as! SpeciImageCollectionViewController
                        actualView.imageArray = (selectedSpeci?.sortedImages())!
                        let speciImages = (selectedSpeci?.images)! as NSSet
                        print("NSET Count\(speciImages.count)")
                        print("Actual Image Count: \(selectedSpeci?.images?.count)")
                        let testTemplate = selectedSpeci!.template! as! Template
                        print("Template Name: \(testTemplate.templateName!)")
                        
                    }
                
                    if viewController is UIPageViewController{
                        let actualView = viewController as! UIPageViewController
                        actualView.dataSource = self
                        let pageContentViewController = self.viewControllerAtIndex(0)
                        actualView.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
                        
                    }
                
            
                    if viewController is MVWebViewController
                    {
                            let actualViewController = viewController as! MVWebViewController
                            actualViewController.speci = selectedSpeci
                            if actualViewController.title == "Details"{
                            actualViewController.templateFilename = "template-iphone-details.html"
                                
                            }
                        if actualViewController.title == "Scarcity"{
                            actualViewController.templateFilename = "template-iphone-scarcity.html"
                        }
                    }
                
                if viewController is AudioTableViewController{
                    let actualViewController = viewController as! AudioTableViewController
                    if selectedSpeci?.audios?.count > 0{
                        actualViewController.audiolist = (selectedSpeci?.sortedAudio())!
                    }
                    else
                    {
                        //TODO: Make Audio Tab inactive.
                        actualViewController.tabBarItem.enabled = false
                    }
                    
                }
            }
       
        
        }*/
        
       tabSetup()
        
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //tabSetup()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //tabSetup()
    }
    //Setup Code
    
    func tabSetup(){
        
        // Do any additional setup after loading the view.
        // Re - sort the  tab controllers according to the template
        //
        
        if let currentTemplate:Template = self.selectedSpeci!.template as? Template{
            
            let templateTabs = currentTemplate.templateTabs()
            var imageViewController:UIPageViewController?
            var audioViewController:AudioTableViewController?
            var webViewControllers:[MVWebWrapperViewController] = []

            
            if let finalViewControllers = self.viewControllers{
                for viewController in finalViewControllers{
                    
                    if viewController  is UIPageViewController{
                        imageViewController = viewController as? UIPageViewController
                        imageViewController!.dataSource = self
                        let pageContentViewController = self.viewControllerAtIndex(0)
                        imageViewController!.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
                    }
                    if viewController is AudioTableViewController  {
                        audioViewController = viewController as? AudioTableViewController
                        if selectedSpeci?.audios?.count > 0{
                            audioViewController?.audiolist = (selectedSpeci?.sortedAudio())!
                                }
                         else
                                                    {
                           audioViewController?.tabBarItem.enabled = false
                       }

                        
                    }
                    if viewController is MVWebWrapperViewController{
                        webViewControllers.append(viewController as! MVWebWrapperViewController)
                    }
                    
                }

            var webviewTabCount = 0
                self.viewControllers?.removeAll()
            for templateTab in templateTabs{
                if templateTab.tabName == "images" || templateTab.tabName == "image"{
                self.viewControllers!.append(imageViewController!)
                }
                else if templateTab.tabName == "audio"{
                    self.viewControllers!.append(audioViewController!)
                }
                else  //webview tab
                {
                    if webviewTabCount <= webViewControllers.count - 1 //value
                    {
                      //  var webViewController = webViewControllers[webviewTabCount] as MVWebWrapperViewController
                        let webViewController:MVWebWrapperViewController = MVWebWrapperViewController(nibName: "MVWebWrapperViewController", bundle: nil)
                        webviewTabCount += 1
                        webViewController.speci = selectedSpeci
                        webViewController.title = templateTab.tabLabel
                        webViewController.templateFilename = templateTab.tabTemplate ?? ""
             
                        webViewController.tabBarItem.image = UIImage(named:templateTab.tabIcon ?? "missingimage.jpg" )
                        self.viewControllers!.append(webViewController)
                        
                    }
                    
                }
                
            }               
            
            
            
            }

            
            
            
            //cycle through view controllers and add appropriate values
            
//            if let finalViewControllers = self.viewControllers{
//                //views may not be in the correct positions
//                for viewController in finalViewControllers{
//                    
//                    if viewController is SpeciImageCollectionViewController
//                    {
//                        let actualView = viewController as! SpeciImageCollectionViewController
//                        actualView.imageArray = (selectedSpeci?.sortedImages())!
//                        let speciImages = (selectedSpeci?.images)! as NSSet
//                        print("NSET Count\(speciImages.count)")
//                        print("Actual Image Count: \(selectedSpeci?.images?.count)")
//                        let testTemplate = selectedSpeci!.template! as! Template
//                        print("Template Name: \(testTemplate.templateName!)")
//                        
//                    }
//                    
//                    if viewController is UIPageViewController{
//                        if self.selectedSpeci?.images?.count > 0 {
//                            let actualView = viewController as! UIPageViewController
//                            actualView.dataSource = self
//                            let pageContentViewController = self.viewControllerAtIndex(0)
//                            actualView.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
//                        }
//                    }
//                    
//                    
//                    if viewController is MVWebWrapperViewController
//                    {
//                        // let actualViewController = viewController as! MVWebViewController
//                        let actualViewController = viewController as! MVWebWrapperViewController
//                        actualViewController.speci = selectedSpeci
//                        if actualViewController.title == "Details"{
//                            actualViewController.templateFilename = "template-iphone-details.html"
//                            
//                        }
//                        if actualViewController.title == "Scarcity"{
//                            actualViewController.templateFilename = "template-iphone-scarcity.html"
//                        }
//                    }
//                    
//                    if viewController is AudioTableViewController{
//                        let actualViewController = viewController as! AudioTableViewController
//                        if selectedSpeci?.audios?.count > 0{
//                            actualViewController.audiolist = (selectedSpeci?.sortedAudio())!
//                        }
//                        else
//                        {
//                            //TODO: Make Audio Tab inactive.
//                            actualViewController.tabBarItem.enabled = false
//                        }
//                        
//                    }
//                }
//                
//                
//            }
        }
        
        
    }
    
    
    // PageView Data Source Functions
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    
    var index = (viewController as! PageContentViewController).pageIndex
    index += 1
        if let realSpeci = self.selectedSpeci{
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
        
        if let realSpeci = self.selectedSpeci{
            if((realSpeci.sortedImages().count == 0) || (index >= realSpeci.sortedImages().count )) {
                return nil
            }
            let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageContentController") as! PageContentViewController
           // var imageArray = self.selectedSpeci!.sortedImages()
            pageContentViewController.imageFile = realSpeci.sortedImages()[index].filename?.FileLocation ?? ""
            pageContentViewController.descriptionText = realSpeci.sortedImages()[index].imageDescription ?? ""
            pageContentViewController.creditText = realSpeci.sortedImages()[index].credit ?? ""
            pageContentViewController.altText = realSpeci.sortedImages()[index].altText ?? ""
            pageContentViewController.pageIndex = index
            pageContentViewController.delegate = self;
            return pageContentViewController
        }else
        {
            return nil
        }
        
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.selectedSpeci?.images?.count ?? 0
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
    return 0
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
