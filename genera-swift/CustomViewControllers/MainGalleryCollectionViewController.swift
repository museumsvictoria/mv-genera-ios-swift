//
//  MainGalleryCollectionViewController.swift
//  genera-swift
//
//  Created by Simon Sherrin on 17/02/2016.
/*

 Copyright (c) 2016 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

var imageArray: [Image] = [Image]()

class MainGalleryCollectionViewController: UICollectionViewController {

     var managedObjectContext:NSManagedObjectContext? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //  self.collectionView!.registerClass(MainGalleryCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        let application = UIApplication.shared.delegate as! AppDelegate
        self.managedObjectContext = application.managedObjectContext
        
        //Load Image Gallery Images
        loadGalleryImages()
        
        // Do any additional setup after loading the view.
        
        //check if it's parent is a tab view controller
        if self.parent?.parent is iPhoneMainTabBarController
        {
            print("in Tab Bar Controller")
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "showFullScreen" {
            let controller = (segue.destination as! SpeciImageCollectionViewController)
            controller.imageArray = imageArray
            if self.parent?.parent is iPhoneMainTabBarController
            {
                if let mainTabBar = self.parent?.parent as? iPhoneMainTabBarController   {
                    controller.delegate = mainTabBar
                }
            }
            if let indexPath = self.collectionView?.indexPath(for: sender as! MainGalleryCollectionViewCell) {
                let selectedCell = (indexPath as NSIndexPath).row
                controller.currentIndex = selectedCell
              //  controller.parentFrameSize = self.collectionView?.bounds
            }
        }
        
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MainGalleryCollectionViewCell
        cell.backgroundColor = UIColor.blue
        let cellImage = imageArray[(indexPath as NSIndexPath).row]
        let thumbnailFilename: String = cellImage.filename?.replacingOccurrences(of: ".", with: "_tmb.") ?? "placeholder.jpg"
        cell.thumbnailImageView.image = UIImage(contentsOfFile: thumbnailFilename.FileLocation )

        return cell
    }

    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
       // self.collectionView?.performBatchUpdates(nil, completion: nil)
        self.collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    
    func loadGalleryImages(){
        //get gallery objects
        let predicate = NSPredicate(format:"title='Primary'")
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> =  NSFetchRequest(entityName:"Gallery")
        fetchRequest.predicate = predicate
        do{
            let currentGallery:[Gallery] =  try self.managedObjectContext!.fetch(fetchRequest) as! [Gallery]
            if currentGallery.count > 0 {
                let primaryGallery = currentGallery[0]
                imageArray = (primaryGallery.images?.allObjects as? [Image]) ?? [Image]()
                imageArray.sort(by: {$0 < $1})
            }
            
        }catch{
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
            
       /*     let flickrPhoto =  photoForIndexPath(indexPath)
            //2
            if var size = flickrPhoto.thumbnail?.size {
                size.width += 10
                size.height += 10
                return size
            }*/
            if self.traitCollection.userInterfaceIdiom  == UIUserInterfaceIdiom.pad{
                if(UIDevice.current.orientation.isLandscape){
                    let onefifth = (collectionView.bounds.size.width-60)/5.0
                    return CGSize(width: onefifth, height: onefifth)
                }
                else
                {
                    let onefourth = (collectionView.bounds.size.width-50)/4.0
                    return CGSize(width: onefourth, height: onefourth)
                }
                
              
            }else
            {
                if(UIDevice.current.orientation.isLandscape){
                    let onefifth = (collectionView.bounds.size.width-40)/5.0
                    return CGSize(width: onefifth, height: onefifth)
                }
                else
                {
                let onethird = (collectionView.bounds.size.width-30)/3.0
                return CGSize(width: onethird, height: onethird)
                }
            }
            
    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
