//
//  iPadHomeViewController.swift
//  genera-swift
//
//  Created by Simon Sherrin on 9/05/2016.
/*

 Copyright (c) 2016 Museum Victoria
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//

import UIKit

class iPadHomeViewController: UIViewController {

    @IBOutlet weak var DatabaseBuildProgress: UIProgressView!
    @IBOutlet weak var DatabaseBuildingActivity: UIActivityIndicatorView!
    @IBOutlet weak var DatabaseBuildingLabel: UILabel!
    
    @IBOutlet weak var btnAbout: UIButton!
    @IBOutlet weak var btnGallery: UIButton!
    @IBOutlet weak var btnAnimalTopContstrait: NSLayoutConstraint!
    @IBOutlet weak var btnAnimals: UIButton!
    @IBOutlet weak var HomeBackgroundImage: UIImageView!
    var delegate:iPadHomeViewControllerDelegate! = nil
    weak var aboutWebViewController:MVWebWrapperViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DatabaseBuildingActivity.stopAnimating()
        
        if UIDevice.current.orientation.isLandscape {
            setHomePageLandscape()
        }
        if ((UIApplication.shared.delegate as! AppDelegate).buildingDatabase){
            //Subscribe to finish Building Notification
            NotificationCenter.default.addObserver(self, selector: #selector(databaseBuildFinished), name:NSNotification.Name(rawValue: NotificationType.DidRefreshDatabase), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(databasePercentComplete(_:)), name:NSNotification.Name(rawValue: NotificationType.DatabasePercentComplete), object: nil)
            self.hideButtons()
            
            DatabaseBuildingActivity.isHidden = false;
            DatabaseBuildingActivity.startAnimating()
            DatabaseBuildProgress.isHidden = false;
            DatabaseBuildingLabel.isHidden = false;
        }else{
            //check gallery setup
            if !LocalDefaults.sharedInstance.hasGallery {
                btnGallery.isHidden = true
            }
        }
        
    }
 
    @objc func databaseBuildFinished(_ notification: Notification){
        //No longer need the notification - remove
        NotificationCenter.default.removeObserver(self)
        self.showButtons()
        DatabaseBuildingActivity.stopAnimating()
        DatabaseBuildingActivity.isHidden = true;
        DatabaseBuildProgress.isHidden = true;
        DatabaseBuildingLabel.isHidden = true;
        
        
    }
    
    @objc func databasePercentComplete(_ notification:Notification){
        
        if let percentage = (notification as NSNotification).userInfo?["percentage"] as? Float{
            
            if !DatabaseBuildProgress.isHidden {
            
                DatabaseBuildProgress.progress = percentage
            }
        }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "embedAboutViewController"{
            aboutWebViewController = segue.destination as? MVWebWrapperViewController
            
        }
        
    }
 

    @IBAction func showMasterList(_ sender: AnyObject) {
        delegate.showMaster()  
        
    }
    
    
    @IBAction func showAbout(_ sender: AnyObject) {

        homePageInactive()
        aboutWebViewController!.nudgeUpContent()

        delegate.aboutShown() //activates Home Button
    }
    
    func hideAbout(){
        

        self.view.layoutIfNeeded()
        self.btnAbout.alpha = 0;
        self.btnAnimals.alpha = 0;
        self.btnGallery.alpha = 0;
        self.HomeBackgroundImage.alpha = 0;
        self.showButtons()
        self.HomeBackgroundImage.isHidden = false;
        UIView.animate(withDuration: 1.0, animations:{
           self.aboutWebViewController!.returnToTop()
            self.btnAbout.alpha = 1;
            self.btnAnimals.alpha = 1;
            self.btnGallery.alpha = 1;
           
            } , completion: {finished in if(finished){
                    self.HomeBackgroundImage.alpha = 1;
                                // need to work on animation in and out.
                }
            
            })
    }
    
    func homePageActive(){
        
       // btnAbout.enabled = true;
        self.showButtons()

        self.HomeBackgroundImage.isHidden = false
        
    }
    
    func homePageInactive(){
        self.hideButtons()

        self.HomeBackgroundImage.isHidden = true
        
    }
    
    func setHomePageLandscape(){
        HomeBackgroundImage.image = UIImage(named:"home-landscape.png")
      //  btnAnimalTopContstrait.constant = -75
        
    }
    
    func setHomePagePortrait(){
        HomeBackgroundImage.image = UIImage(named:"home-portrait.png")
      //  btnAnimalTopContstrait.constant = -125
    }
    
    func hideButtons(){
        btnAbout.isHidden = true;
        btnAnimals.isHidden = true;
        btnGallery.isHidden = true; 
    }
    
    func showButtons(){
        
        btnAbout.isHidden = false;
        btnAnimals.isHidden = false;
        //only show Gallery button if Gallery exists
        if LocalDefaults.sharedInstance.hasGallery{
            btnGallery.isHidden = false;
        }
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
           setHomePageLandscape()
        } else {
           setHomePagePortrait()
        }
    }
    

    
    
}

    // delegate Protocol
    
    protocol iPadHomeViewControllerDelegate {
        func aboutHidden()
        func aboutShown()
        func showMaster()
    }


