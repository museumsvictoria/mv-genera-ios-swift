 //
//  SpeciImageCollectionViewController.swift
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
private let reuseIdentifier = "Cell"

class SpeciImageCollectionViewController: UICollectionViewController {

    
    var imageArray: [Image]  = [Image]()
    var currentIndex = 0
    var viewDidLayoutSubviewsForTheFirstTime:Bool = false
    
    weak var delegate:SpeciImageCollectionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
   
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        // self.collectionView!.registerClass(CustomCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.

        self.collectionView!.contentOffset = CGPoint(x: 0,y: 0)
        self.collectionView!.invalidateIntrinsicContentSize()
        //Disable prefetching for the gallery.
        if #available(iOS 10.0, *) {
            self.collectionView!.isPrefetchingEnabled = false
        } else {
            // Fallback on earlier versions
        };

        self.title = ""
        
        //Setup Single Tap
        let aSelector : Selector = #selector(SpeciImageCollectionViewController.switchFullScreen(_:))
        let singleTap = UITapGestureRecognizer(target:self, action: aSelector)
        singleTap.numberOfTapsRequired = 1
        let doubleTap = UITapGestureRecognizer(target:self, action: nil)
        doubleTap.numberOfTapsRequired = 2
        singleTap.require(toFail: doubleTap)
        
        self.view.addGestureRecognizer(singleTap)
         self.view.addGestureRecognizer(doubleTap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     //   collectionView?.collectionViewLayout.invalidateLayout()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !viewDidLayoutSubviewsForTheFirstTime{
            self.collectionView!.contentOffset = CGPoint(x: 0,y: 0)
            self.collectionView!.collectionViewLayout.invalidateLayout()
           
         //   self.collectionView!.collectionViewLayout.collectionViewContentSize()
          
            let currentSize = self.collectionView!.bounds.size;
            let offset = CGFloat(self.currentIndex) * currentSize.width;
            self.collectionView!.contentOffset = CGPoint(x: offset, y: 0)
            
            viewDidLayoutSubviewsForTheFirstTime = true
        }else{
            
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.imageArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SpeciImageCollectionViewCell
        
       cell.imageDescriton?.attributedText = imageArray[(indexPath as NSIndexPath).row].imageDescription?.AttributedString()
    
       cell.imageCredit?.attributedText = imageArray[(indexPath as NSIndexPath).row].credit?.AttributedString()
       cell.altText = imageArray[(indexPath as NSIndexPath).row].altText ?? ""
        

        
        
        
        
      //  cell.imageView.image = UIImage(named: "placeholder.jpg")
        //get image in background
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            if let imageSource = self.imageArray[(indexPath as NSIndexPath).row].filename?.FileLocation{
                if let image:UIImage = UIImage(contentsOfFile: imageSource){
                    
                    
                    DispatchQueue.main.async {
                        // update some UI
                        
                        if let cellToUpdate = collectionView.cellForItem(at: indexPath) as? SpeciImageCollectionViewCell {
                            // cellToUpdate.imageView.image = image
                            cellToUpdate.scrollableImageView.displayImage = image
                        }
                        
                    }
                }
            }
            
        }

        print("Index:\((indexPath as NSIndexPath).row)")
        
    
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    {
     
      return collectionView.frame.size
        
        
   
    
    }
/* depricated in iOS 8
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        //let currentOffset = self.collectionView!.contentOffset;
        //self.currentIndex = Int(currentOffset.x / self.collectionView!.frame.size.width);
        print("after\(self.collectionView!.contentOffset)")
        print("\(self.collectionView!.frame.size.width)")
        print("\(self.collectionView!.bounds.size.height)")
        self.collectionView?.collectionViewLayout.invalidateLayout()
    }

    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
   //   let currentSize = self.collectionView!.bounds.size;
   //   let offset = CGFloat(self.currentIndex) * currentSize.width;
   //   self.collectionView!.contentOffset = CGPointMake(offset, 0)
        print("willAnimateRotate\(self.currentIndex)")
        print("\(self.collectionView!.contentOffset)")
        print("\(self.collectionView!.frame.size.width)")
    }
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        let currentSize = self.collectionView!.bounds.size;
        let offset = CGFloat(self.currentIndex) * currentSize.width;
        self.collectionView!.contentOffset = CGPointMake(offset, 0)
    }

  */
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
         //Make sure the currentIndex is up to date - will always pic the first image if the rotation happens when inbetween pages
        print("width:\(size.width)")
        var testCell:SpeciImageCollectionViewCell?
        if let visibleCells = self.collectionView?.visibleCells{
            if (visibleCells.count > 0){
                let currentCell = visibleCells[0] as! SpeciImageCollectionViewCell
                testCell = currentCell
                print("ScrollableImageViewFrame:\(currentCell.scrollableImageView.frame)")
     
                if let currentIndexPath = self.collectionView?.indexPath(for: currentCell){
                   self.currentIndex = (currentIndexPath as NSIndexPath).row
                }
               
            }
        }
        

        
         self.collectionView?.collectionViewLayout.invalidateLayout()
        
        if (testCell != nil){
            // testCell!.scrollableImageView.centerScrollViewContents()
            print("PreAnimating ScrollableImageViewFrame:\(testCell!.scrollableImageView.frame)")
            print("PreAnimating Image Credit:\(testCell!.imageCredit.frame)")
            print("PreAnimating Cell ContentView Frame: \(String(describing: testCell?.contentView.frame))")
        }
        
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            
            let offset = CGFloat(self.currentIndex) * size.width
            self.collectionView?.contentOffset = CGPoint(x: offset, y: 0)
          
            if (testCell != nil){
                // testCell!.scrollableImageView.centerScrollViewContents()
                print("Animating ScrollableImageViewFrame:\(testCell!.scrollableImageView.frame)")
                print("Animating Image Credit:\(testCell!.imageCredit.frame)")
                print("Animating Cell ContentView Frame: \(String(describing: testCell?.contentView.frame))")
            }
            let orient = UIApplication.shared.statusBarOrientation
            
            switch orient {
            case .portrait:
                print("Portrait")
            // Do something
            default:
                print("Anything But Portrait")
                // Do something else
            }
            
            }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
                print("rotation completed")
                if (testCell != nil){
                    // testCell!.scrollableImageView.centerScrollViewContents()
                    print("Final ScrollableImageViewFrame:\(testCell!.scrollableImageView.frame)")
                    print("Final Image Credit:\(testCell!.imageCredit.frame)")
                    print("Final Cell ContentView Frame: \(String(describing: testCell?.contentView.frame))")
                }
        })
        
        super.viewWillTransition(to: size, with: coordinator)

        

        
    }
    
    
    
    @objc func switchFullScreen(_ sender:UITapGestureRecognizer){
            
        if delegate != nil {
            print("in Tab Controller")
            
            if let navcontroller = self.navigationController {
                if (navcontroller.isNavigationBarHidden){
                    delegate?.tabBar.isHidden = false
                    navcontroller.setNavigationBarHidden(false, animated: true)
                    UIApplication.shared.setStatusBarHidden(false, with: .slide)
                    
                }else
                {
                    
                    delegate?.tabBar.isHidden = true
                    navcontroller.setNavigationBarHidden(true, animated: true)
                    UIApplication.shared.setStatusBarHidden(true, with: .slide)
                    
                }
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
 
 protocol SpeciImageCollectionViewControllerDelegate:class{
    
     var tabBar:UITabBar{get}
    
 }
 
