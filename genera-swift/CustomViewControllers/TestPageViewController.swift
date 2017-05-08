//
//  TestPageViewController.swift
//  genera-swift
//
//  Created by Simon Sherrin on 19/02/2016.
/*

 Copyright (c) 2016 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

import UIKit
import CoreData

class TestPageViewController: UIPageViewController, UIPageViewControllerDataSource {

    
    var images: [Image] = [Image]()
    
    //testing
    var managedObjectContext: NSManagedObjectContext? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let application = UIApplication.shared.delegate as! AppDelegate
        self.managedObjectContext = application.managedObjectContext
        loadGalleryImages()
        
        dataSource = self
        if let firstViewController = getItemController(0) {
            setViewControllers([firstViewController],
                direction: .forward,
                animated: true,
                completion: nil)
        }
        setupPageControl()
        // Do any additional setup after loading the view.
    }
    
    //testing
    func loadGalleryImages(){
        //get gallery objects
        let predicate = NSPredicate(format:"title='Primary'")
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName:"Gallery")
        fetchRequest.predicate = predicate
        do{
            let currentGallery:[Gallery] =  try self.managedObjectContext!.fetch(fetchRequest) as! [Gallery]
            if currentGallery.count > 0 {
                let primaryGallery = currentGallery[0]
                imageArray = (primaryGallery.images?.allObjects as! [Image]) ?? [Image]()
                imageArray.sort(by: {$0 > $1})
                images.append(imageArray[0])
                images.append(imageArray[1])
                images.append(imageArray[2])
            }
            
        }catch{
            
        }
    }

    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    fileprivate func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.gray
        appearance.currentPageIndicatorTintColor = UIColor.white
        appearance.backgroundColor = UIColor.darkGray
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! SpeciImageViewController
        
        if itemController.index > 0 {
            return getItemController(itemController.index-1)
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! SpeciImageViewController
        
        if itemController.index+1 < images.count {
            return getItemController(itemController.index+1)
        }
        
        return nil
    }
    
    fileprivate func getItemController(_ itemIndex: Int) -> SpeciImageViewController? {
        
        if itemIndex < images.count {
            let pageItemController = self.storyboard!.instantiateViewController(withIdentifier: "SpeciImageView") as! SpeciImageViewController
            pageItemController.index = itemIndex
            pageItemController.image = UIImage(contentsOfFile: (images[itemIndex].filename?.FileLocation)!)
            pageItemController.imageDescription = images[itemIndex].imageDescription ?? ""
            pageItemController.credit = images[itemIndex].credit ?? ""
            
            return pageItemController
        }
        
        return nil
    }
    
    // MARK: - Page Indicator
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return images.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
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
