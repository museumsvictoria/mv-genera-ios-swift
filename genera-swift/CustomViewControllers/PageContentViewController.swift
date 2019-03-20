//
//  PageContentViewController.swift
//  genera-swift
//
//  Created by Simon Sherrin on 11/03/2016.
/*

 Copyright (c) 2016 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

import UIKit

class PageContentViewController: UIViewController {

    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: ImageScrollView!
    
    var pageIndex = 0
    var descriptionText = ""
    var creditText = ""
    var imageFile = ""
    var altText:String = ""
        {
        didSet{
            if imageView != nil{
                imageView.altText = altText
            }
        }
    }
    weak var delegate:AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.black
        
        //Catch Single Tap to Hide Chrome
        let aSelector : Selector = #selector(PageContentViewController.showHideChrome(_:))
        let singleTap = UITapGestureRecognizer(target:self, action: aSelector)
        singleTap.numberOfTapsRequired = 1
        
        let doubleTap = UITapGestureRecognizer(target:self, action: nil)
        doubleTap.numberOfTapsRequired = 2
        singleTap.require(toFail: doubleTap)
        self.view.addGestureRecognizer(singleTap)
        self.view.addGestureRecognizer(doubleTap)
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    
        

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func viewWillLayoutSubviews() {
        
 
        self.creditLabel.attributedText = creditText.AttributedString()
        self.descriptionLabel.attributedText = descriptionText.AttributedString()
        self.descriptionLabel.sizeToFit()


    }
    
    override func viewDidLayoutSubviews() {

        self.imageView.displayImage = UIImage(contentsOfFile: imageFile)
        if imageView != nil{
            imageView.altText = altText
        }
    }
    
    
    @objc func showHideChrome(_ sender:UITapGestureRecognizer){
        
        print("Single Tap Fired")
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
    
    
    
}

protocol PageContentViewControllerDelegate: class {
     var tabBar: UITabBar {get}
}

